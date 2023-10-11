import 'user.dart';

class AuthenticatedUser extends User {
  final bool isAdmin;
  final String email;
  final bool? acceptedToReview;

  AuthenticatedUser(
      super.id, super.name, super.points, this.isAdmin, this.email, this.acceptedToReview);

  AuthenticatedUser withAdditionalPoints(double additionalPoints) {
    return AuthenticatedUser(id, name, points + additionalPoints, isAdmin, email, acceptedToReview);
  }
}
