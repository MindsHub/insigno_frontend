import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:insigno_frontend/provider/location_info.dart';
import 'package:os_detect/os_detect.dart' as Platform;

@lazySingleton
class LocationProvider {
  static var locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1, // meters
      forceLocationManager: true,
      intervalDuration: const Duration(milliseconds: 500));

  StreamSubscription<LocationPermission>? _permissionStatusSub;
  StreamSubscription<ServiceStatus>? _serviceStatusSub;
  StreamSubscription<bool>? _initialServiceStatusSub;
  StreamSubscription<Position>? _positionSub;

  final LocationInfo _lastLocationInfo = LocationInfo(null, true, true);
  final StreamController<LocationInfo> _streamController = StreamController.broadcast();

  LocationProvider() {
    if (Platform.isLinux) {
      // hardcoded for debugging purporses
      _handlePosition(Position(
        longitude: 11.00323,
        latitude: 45.75548,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      ));
      return;
    }
    _permissionStatusSub = Geolocator.checkPermission().asStream().listen((permission) async {
      debugPrint("Location permission status $permission");
      await _handlePermission(permission, true);
    });

    try {
      _serviceStatusSub = Geolocator.getServiceStatusStream().listen((status) async {
        debugPrint("Location status $status");
        await _handleServicesEnabled(status == ServiceStatus.enabled, false);
      });
      _initialServiceStatusSub =
          Geolocator.isLocationServiceEnabled().asStream().listen((enabled) async {
        debugPrint("Initial location status $enabled");
        await _handleServicesEnabled(enabled, true);
      });
    } catch (e) {
      // service status is not available on the web
      debugPrint("No service status available: $e");
    }

    _createNewPositionStream();
  }

  Stream<LocationInfo> getLocationStream() {
    return _streamController.stream;
  }

  LocationInfo lastLocationInfo() {
    return _lastLocationInfo;
  }

  void _createNewPositionStream() {
    debugPrint("Creating new position stream");
    _positionSub = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (position) => _handlePosition(position),
        onError: (error) => debugPrint("Position stream error: $error"));
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
  Future<void> dispose() async {
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
