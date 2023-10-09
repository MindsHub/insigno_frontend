import 'package:insigno_frontend/networking/data/marker_type.dart';

class ImageVerification {
  final int imageId;
  final int markerId;
  final bool? verdict;
  final MarkerType markerType;
  final List<int> markerImages;

  ImageVerification(this.imageId, this.markerId, this.verdict, this.markerType, this.markerImages);
}