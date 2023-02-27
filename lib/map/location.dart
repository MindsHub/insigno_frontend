import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:insignio_frontend/map/location_info.dart';

@lazySingleton
class LocationProvider {
  static var locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 1, // meters
    forceLocationManager: true,
  );

  StreamSubscription<LocationPermission>? _permissionStatusSub;
  StreamSubscription<ServiceStatus>? _serviceStatusSub;
  StreamSubscription<Position>? _positionSub;

  final LocationInfo _lastLocationInfo = LocationInfo(null, true, true);
  final StreamController<LocationInfo> _streamController = StreamController.broadcast();

  LocationProvider() {
    _permissionStatusSub = Geolocator.checkPermission()
      .asStream()
      .listen((permission) async => await _handlePermission(permission, true));

    _serviceStatusSub = Geolocator.getServiceStatusStream().listen((status) async {
      print(status.toString() + "##########");
      try {
        print(status.toString() + " - " + (await Geolocator.getCurrentPosition()).toString());
      } catch (e) {
        print("Exception " + e.toString());
      }
      print(status.toString() + "##########");
      _handleMetadata(servicesEnabled: status == ServiceStatus.enabled);
    });
    _createNewPositionStream();
  }

  Stream<LocationInfo> getLocationStream() {
    return _streamController.stream;
  }

  LocationInfo lastLocationInfo() {
    return _lastLocationInfo;
  }

  void _createNewPositionStream() {
    _positionSub = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (position) => _handlePosition(position),
        onError: (error) => print(error.toString()));
  }

  void _handlePosition(Position? position) {
    if (position != null) {
      _lastLocationInfo.position = position;
      _lastLocationInfo.servicesEnabled = true;
      _lastLocationInfo.permissionGranted = true;
      _streamController.add(_lastLocationInfo);
    }
  }

  Future<void> _handlePermission(LocationPermission permission, bool initialCheck) async {
    switch (permission) {
      case LocationPermission.unableToDetermine:
      case LocationPermission.denied:
        _handleMetadata(permissionGranted: false);
        if (initialCheck) {
          LocationPermission newPermission = await Geolocator.requestPermission();
          await _handlePermission(newPermission, false);
        }
        break;
      case LocationPermission.deniedForever:
        await _positionSub?.cancel();
        _handleMetadata(permissionGranted: false);
        break;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        _handleMetadata(permissionGranted: true);
        if (!initialCheck) {
          // reopen the position stream only if the permission was not granted at the beginning but
          // then, upon asked for permission with requestPermission, the user granted the permission
          await _positionSub?.cancel();
          _createNewPositionStream();
        }
        break;
    }
  }

  void _handleMetadata({bool? servicesEnabled, bool? permissionGranted}) {
    if (servicesEnabled != null) {
      _lastLocationInfo.servicesEnabled = servicesEnabled;
      if (!servicesEnabled) {
        _lastLocationInfo.position = null;
      }
    }
    if (permissionGranted != null) {
      _lastLocationInfo.permissionGranted = permissionGranted;
    }
    _streamController.add(_lastLocationInfo);
  }

  @disposeMethod
  void dispose() async {
    await Future.wait([
      _permissionStatusSub?.cancel() ?? Future.value(null),
      _serviceStatusSub?.cancel() ?? Future.value(null),
      _positionSub?.cancel() ?? Future.value(null),
      _streamController.close()
    ]);
    _positionSub = null;
  }
}
