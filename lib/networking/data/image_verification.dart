import 'package:insigno_frontend/networking/data/marker_type.dart';

class ImageVerification {
  final int imageId;
  final int markerId;
  final bool? verdict;
  final MarkerType markerType;
  final List<int> markerImages;

  ImageVerification(this.imageId, this.markerId, this.verdict, this.markerType, this.markerImages);
}

class VerifyTime {
  final DateTime? dateTime;
  final bool? isAcceptingToReviewPending;

  VerifyTime.date(DateTime this.dateTime) : isAcceptingToReviewPending = null;
  VerifyTime.notAcceptedYet(bool this.isAcceptingToReviewPending) : dateTime = null;
  VerifyTime.empty() : dateTime = null, isAcceptingToReviewPending = false;

  bool shouldShowMessage() {
    return dateTime != null || isAcceptingToReviewPending == true;
  }

  bool canVerifyNow() {
    // the user can review now if the returned date is before now, or if there is no returned date
    // but only in the case the user has not specified whether he wants to accept reviewing yet
    return dateTime?.isBefore(DateTime.now()) ?? (isAcceptingToReviewPending == true);
  }
}