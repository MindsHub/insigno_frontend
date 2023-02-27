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
  StreamSubscription<bool>? _initialServiceStatusSub;
  StreamSubscription<Position>? _positionSub;

  final LocationInfo _lastLocationInfo = LocationInfo(null, true, true);
  final StreamController<LocationInfo> _streamController = StreamController.broadcast();

  LocationProvider() {
    _initialServiceStatusSub =
        Geolocator.isLocationServiceEnabled().asStream().listen((enabled) async {
      await _handleServicesEnabled(enabled, true);
    });

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
      await _handleServicesEnabled(status == ServiceStatus.enabled, false);
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
        await _handlePermissionGranted(false);
        if (initialCheck) {
          LocationPermission newPermission = await Geolocator.requestPermission();
          await _handlePermission(newPermission, false);
        }
        break;
      case LocationPermission.deniedForever:
        await _positionSub?.cancel();
        await _handlePermissionGranted(false);
        break;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        await _handlePermissionGranted(true);
        if (!initialCheck) {
          // reopen the position stream only if the permission was not granted at the beginning but
          // then, upon asked for permission with requestPermission, the user granted the permission
          await _positionSub?.cancel();
          _createNewPositionStream();
        }
        break;
    }
  }

  Future<void> _handleServicesEnabled(bool enabled, bool initialCheck) async {
    if (enabled) {
      if (!initialCheck) {
        _createNewPositionStream();
      }
    } else {
      await _positionSub?.cancel();
      _lastLocationInfo.position = null;
    }
    _lastLocationInfo.servicesEnabled = enabled;
    _streamController.add(_lastLocationInfo);
  }

  Future<void> _handlePermissionGranted(bool permissionGranted) async {
    _lastLocationInfo.permissionGranted = permissionGranted;
    _streamController.add(_lastLocationInfo);
  }

  @disposeMethod
  void dispose() async {
    await Future.wait([
      _permissionStatusSub?.cancel() ?? Future.value(null),
      _serviceStatusSub?.cancel() ?? Future.value(null),
      _initialServiceStatusSub?.cancel() ?? Future.value(null),
      _positionSub?.cancel() ?? Future.value(null),
      _streamController.close()
    ]);
    _positionSub = null;
  }
}
