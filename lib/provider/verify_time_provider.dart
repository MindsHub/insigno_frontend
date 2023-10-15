import 'dart:async';

import 'package:async/async.dart';
import 'package:injectable/injectable.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/image_verification.dart';

@lazySingleton
class VerifyTimeProvider {
  final Backend _backend;
  final Authentication _authentication;

  CancelableOperation<void>? _backendRequestSub;
  late final CancelableOperation<void> _isLoggedInStreamSub;

  VerifyTime _currentVerifyTime = VerifyTime.empty();
  final StreamController<VerifyTime> _verifyTimeController = StreamController.broadcast();

  VerifyTimeProvider(this._backend, this._authentication) {
    _isLoggedInStreamSub =
        CancelableOperation.fromFuture(_authentication.getIsLoggedInStream().forEach(_update));
    update();
  }

  void _update(bool isLoggedIn) {
    if (isLoggedIn == false) {
      _verifyTimeController.add(VerifyTime.empty());
      return;
    }

    _backendRequestSub?.cancel();
    _backendRequestSub = CancelableOperation.fromFuture(
      _backend.getNextVerifyTime().then((value) {
        _currentVerifyTime = value;
        _verifyTimeController.add(value);
      }, onError: (e) {
        // ignore errors
      }),
    );
  }

  void update() {
    _update(_authentication.isLoggedIn());
  }

  void onAcceptedToReviewSettingChanged(bool acceptedToReview) {
    if (acceptedToReview) {
      update();
    } else {
      _currentVerifyTime = VerifyTime.empty();
      _verifyTimeController.add(VerifyTime.empty());
    }
  }

  Stream<VerifyTime> getVerifyTimeStream() {
    return _verifyTimeController.stream;
  }

  VerifyTime getVerifyTime() {
    return _currentVerifyTime;
  }

  @disposeMethod
  Future<void> dispose() async {
    await Future.wait([
      _isLoggedInStreamSub.cancel(),
      _verifyTimeController.close(),
    ]);
  }
}
