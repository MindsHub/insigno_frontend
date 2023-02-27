import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

class OptionalPosition {
  Position? position;

  OptionalPosition(this.position);
}

@lazySingleton
class LocationProvider {
  static const locationSettings =
      LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 1 // meters
          );

  StreamSubscription<ServiceStatus>? _serviceStatusSub;
  StreamSubscription<Position>? _positionSub;
  final StreamController<OptionalPosition> _streamController = StreamController.broadcast();

  LocationProvider() {
    _serviceStatusSub = Geolocator.getServiceStatusStream()
        .listen((status) {
          switch (status) {
            case ServiceStatus.disabled:
              _streamController.add(OptionalPosition(null));
              break;
            case ServiceStatus.enabled:
              break;
          }
    });
    _positionSub = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((position) => _streamController.add(OptionalPosition(position)),
        onError: (error) {});
  }

  Stream<OptionalPosition> getPositionStream() {
    return _streamController.stream;
  }

  @disposeMethod
  void dispose() async {
    await Future.wait([
      _serviceStatusSub?.cancel() ?? Future.value(null),
      _positionSub?.cancel() ?? Future.value(null),
      _streamController.close()
    ]);
    _positionSub = null;
  }
}
