import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';

class OptionalPosition {
  Position? p;

  OptionalPosition(this.p);
}

@lazySingleton
class LocationProvider {
  static const locationSettings =
      LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 1 // meters
          );

  StreamSubscription<Position>? positionStreamSubscription;
  StreamController<OptionalPosition> streamController = StreamController();

  LocationProvider() {
    positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((position) => streamController.add(OptionalPosition(position)),
        onError: (error) => streamController.add(OptionalPosition(null)));
  }

  Stream<OptionalPosition> getPositionStream() {
    return streamController.stream;
  }

  @disposeMethod
  void dispose() async {
    await Future.wait([
      positionStreamSubscription?.cancel() ?? Future.value(null),
      streamController.close()
    ]);
    positionStreamSubscription = null;
  }
}
