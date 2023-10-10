import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/authenticated_user.dart';

@lazySingleton
class AuthUserProvider {
  final Backend _backend;
  AuthenticatedUser? _loadedUser;
  double _additionalPoints = 0;

  final StreamController<AuthenticatedUser> _userStreamController = StreamController.broadcast();
  final StreamController<double> _additionalPointsStreamController = StreamController.broadcast();

  AuthUserProvider(this._backend);

  Future<AuthenticatedUser> requestAuthenticatedUser() async {
    if (_loadedUser == null) {
      final user = await _backend.getAuthenticatedUser();
      _loadedUser = user;
      _additionalPoints = 0;
      _userStreamController.add(user);
    }
    return _loadedUser!;
  }

  /// Do not rely on this stream to detect whether a user is logged in, that's the job of
  /// [Authentication.getIsLoggedInStream]!
  Stream<AuthenticatedUser> getAuthenticatedUserStream() {
    return _userStreamController.stream;
  }

  Stream<double> getAdditionalPointsStream() {
    return _additionalPointsStreamController.stream;
  }

  AuthenticatedUser? getAuthenticatedUserOrNull() {
    return _loadedUser?.withAdditionalPoints(_additionalPoints);
  }

  void addPoints(double points) {
    _additionalPoints += points;
    _additionalPointsStreamController.add(points);

    final u = _loadedUser;
    if (u != null) {
      _userStreamController.add(u.withAdditionalPoints(_additionalPoints));
    }
  }

  /// This will NOT update the authenticated user stream, as it is not the point of this class to
  /// handle user logouts! Use [Authentication.getIsLoggedInStream] for that, instead.
  void invalidateLoadedUser() {
    _loadedUser = null;
  }

  @disposeMethod
  Future<void> dispose() {
    return Future.wait([
      _userStreamController.close(),
      _additionalPointsStreamController.close(),
    ]);
  }
}
