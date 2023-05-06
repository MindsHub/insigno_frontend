import 'user.dart';

class AuthenticatedUser extends User {
  final bool isAdmin;

  AuthenticatedUser(super.id, super.name, super.points, this.isAdmin);
}
