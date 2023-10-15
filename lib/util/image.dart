import 'package:flutter/material.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/server_host_handler.dart';

Image imageFromNetwork({required int imageId, double? height, double? width, BoxFit? fit}) {
  return Image.network(
    getIt<ServerHostHandler>().getUri("/map/image/$imageId").toString(),
    height: height,
    width: width,
    fit: fit,
    loadingBuilder: imageLoadingBuilder,
  );
}

Widget imageLoadingBuilder(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
  if (loadingProgress == null) {
    return child;
  }
  return Center(
    child: CircularProgressIndicator(
      value: loadingProgress.expectedTotalBytes != null
          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
          : null,
    ),
  );
}
