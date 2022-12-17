import 'dart:convert';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:insignio_frontend/map/location.dart';


import '../map/marker_type.dart';
import '../networking/const.dart';
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

Future<bool> addTrash(io.File? img, String? path) async{
  Position? coor= CustomLocation().getPosition();
  if(coor==null||img==null){
    return false;
  }
  var dio = Dio();
  // Set default configs
  dio.options.baseUrl = insigno_server;
  dio.options.connectTimeout = 5000; //5s
  dio.options.receiveTimeout = 3000;

  var formData = FormData.fromMap({
    'x': coor!.latitude.toString(),
    'y': coor!.longitude.toString(),
    'type': MarkerType.unknown.toString(),
    /*await pickedFile.readAsBytes(),
        filename: pickedFile.path.split('/').last,*/
    'image': img!.toString(),
  });
  var response = await dio.post(insigno_server+"/addMarkers", data: formData);
  return response.statusCode==200;

}


