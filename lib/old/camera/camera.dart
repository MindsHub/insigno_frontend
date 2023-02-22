import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../map/location.dart';
import '../marker/marker_type.dart';
import '../networking/const.dart';
import '../authentication.dart';

Future<XFile?> getPictureFromSource() async {
  final ImagePicker _picker = ImagePicker();
  final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
  return photo;
}

Future<XFile?> getPictureFromCamera() async {
  final ImagePicker _picker = ImagePicker();
  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
  return photo;
}

Future<bool> addTrash(Uint8List image) async {
  Position? coor = CustomLocation().getPosition();
  if (coor == null) {
    return false;
  }

  var dio = Dio(BaseOptions(headers: {"Cookie": await getCookie()}));
  // Set default configs
  dio.options.baseUrl = insignio_server;
  dio.options.connectTimeout = 5000; //5s
  dio.options.receiveTimeout = 3000;

  var formData = FormData.fromMap({
    'y': coor.latitude.toString(),
    'x': coor.longitude.toString(),
    'type_tr': MarkerType.unknown.toString(),
  });

  var id;
  try {
        var response = await dio.post(
            insignio_server + "/map/add",
            data: formData
        );
        id = response.data;
  } catch (e) {
    if (e.runtimeType == DioError) {
      var dioException = e as DioError;

      print(dioException.response); // Do something with response
    }

    print(e);
    return false;
  }

  try {
    var response = await dio.post(
        insignio_server + "/map/image/add",
        data: FormData.fromMap({
          'image': MultipartFile.fromBytes(image, contentType: MediaType.parse("image/png")),
          'refers_to_id': id
        })
    );
    return true;
  } catch (e) {
    if (e.runtimeType == DioError) {
      var dioException = e as DioError;

      print(dioException.response); // Do something with response
    }

    print(e);
    return false;
  }
}
