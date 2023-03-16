import 'package:insigno_frontend/networking/data/authenticated_user.dart';

import 'data/user.dart';

User userFromJson(dynamic u) {
  return User(u["id"], u["name"], u["points"]);
}

AuthenticatedUser authenticatedUserFromJson(dynamic u) {
  return AuthenticatedUser(u["id"], u["name"], u["points"]);
}
