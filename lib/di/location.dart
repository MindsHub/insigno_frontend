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

  StreamSubscription<ServiceStatus>? serviceStatusSub;
  StreamSubscription<Position>? positionSub;
  StreamController<OptionalPosition> streamController = StreamController.broadcast();

  LocationProvider() {
    serviceStatusSub = Geolocator.getServiceStatusStream()
        .listen((status) {
          switch (status) {
            case ServiceStatus.disabled:
              streamController.add(OptionalPosition(null));
              break;
            case ServiceStatus.enabled:
              break;
          }
    });
    positionSub = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((position) => streamController.add(OptionalPosition(position)),
        onError: (error) {});
  }

  Stream<OptionalPosition> getPositionStream() {
    return streamController.stream;
  }

  @disposeMethod
  void dispose() async {
    await Future.wait([
      serviceStatusSub?.cancel() ?? Future.value(null),
      positionSub?.cancel() ?? Future.value(null),
      streamController.close()
    ]);
    positionSub = null;
  }
}
