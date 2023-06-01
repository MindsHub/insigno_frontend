import 'user.dart';

class AuthenticatedUser extends User {
  final bool isAdmin;
  final String email;

  AuthenticatedUser(super.id, super.name, super.points, this.isAdmin, this.email);
}
