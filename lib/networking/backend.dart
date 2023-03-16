import "package:collection/collection.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:http_parser/http_parser.dart";
import "package:injectable/injectable.dart";
import "package:insigno_frontend/networking/authentication.dart";
import "package:insigno_frontend/networking/data/authenticated_user.dart";
import "package:insigno_frontend/networking/data/marker.dart";
import "package:insigno_frontend/networking/data/pill.dart";
import "package:insigno_frontend/networking/data/user.dart";
import "package:insigno_frontend/networking/error.dart";
import "package:insigno_frontend/util/future.dart";
import "package:insigno_frontend/util/nullable.dart";

import "const.dart";
import "data/map_marker.dart";
import "data/marker_type.dart";

@lazySingleton
class Backend {
  final http.Client _client;
  final Authentication _auth;

  Backend(this._client, this._auth);

  Future<dynamic> _getJson(String path, {Map<String, dynamic>? params}) {
    return _client //
        .get(Uri(
          scheme: insignoServerScheme,
          host: insignoServer,
          path: path,
          queryParameters: params,
        ))
        .throwErrors()
        .mapParseJson();
  }

  Future<dynamic> _getJsonAuthenticated(String path, {Map<String, dynamic>? params}) async {
    final String? cookie = _auth.maybeCookie();
    if (cookie == null) {
      throw UnauthorizedException(401, "Cookie is null");
    }

    final response = await _client.get(
      Uri(
        scheme: insignoServerScheme,
        host: insignoServer,
        path: path,
        queryParameters: params,
      ),
      headers: {"Cookie": cookie},
    );

    if (response.statusCode == 401) {
      // the authentication token is not valid anymore, so remove it and ask the user to re-login
      _auth.removeStoredCookie();
    }
    return response.throwErrors().mapParseJson();
  }

  Future<http.StreamedResponse> _postAuthenticated(String path,
      {Map<String, String>? fields, List<http.MultipartFile>? files}) async {
    final String? cookie = _auth.maybeCookie();
    if (cookie == null) {
      throw UnauthorizedException(401, "Cookie is null");
    }

    final request = http.MultipartRequest(
        "POST",
        Uri(
          scheme: insignoServerScheme,
          host: insignoServer,
          path: path,
        ));
    request.headers["Cookie"] = cookie;

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (files != null) {
      request.files.addAll(files);
    }

    final response = await _client.send(request);
    if (response.statusCode == 401) {
      // the authentication token is not valid anymore, so remove it and ask the user to re-login
      _auth.removeStoredCookie();
    }
    response.throwErrors();
    return response;
  }

  Future<Pill> loadRandomPill() async {
    return _getJson("/pills/random")
        .map<Pill>((p) => Pill(p["id"], p["text"], p["author"], p["source"], p["accepted"]));
  }

  Future<List<MapMarker>> loadMapMarkers(
      double latitude, double longitude, bool includeResolved) async {
    return _getJson("/map/get_near", params: {
      "y": latitude.toString(),
      "x": longitude.toString(),
      "srid": "4326", // gps
      "include_resolved": includeResolved ? "true" : "false",
    }).map((markers) => markers.map<MapMarker>((marker) {
          var point = marker["point"];
          var resolutionDate = marker["resolution_date"];
          return MapMarker(
            marker["id"],
            point["y"] as double,
            point["x"] as double,
            MarkerType.values.firstWhereOrNull((type) => type.id == marker["marker_types_id"]) ??
                MarkerType.unknown,
            DateTime.parse(marker["creation_date"]),
            (resolutionDate as String?).map(DateTime.parse),
            marker["created_by"],
            marker["solved_by"],
          );
        }).toList());
  }

  Future<int> addMarker(double latitude, double longitude, MarkerType markerType) async {
    var response = await _postAuthenticated("/map/add", fields: {
      "y": latitude.toString(),
      "x": longitude.toString(),
      "marker_types_id": markerType.id.toString(),
    });
    return int.parse(await response.stream.bytesToString());
  }

  Future<void> addMarkerImage(int markerId, Uint8List image, String? mimeType) async {
    await _postAuthenticated("/map/image/add", fields: {
      "refers_to_id": markerId.toString(),
    }, files: [
      http.MultipartFile.fromBytes(
        "image",
        image,
        contentType: mimeType?.map(MediaType.parse) ?? MediaType("image", ""),
      ),
    ]);
  }

  Future<List<int>> getImagesForMarker(int markerId) {
    return _getJson("/map/image/list/$markerId")
        .map((list) => list.map<int>((i) => i as int).toList());
  }

  Future<Marker> getMarker(int markerId) {
    return _getJson("/map/$markerId").map((marker) {
      var point = marker["point"];
      var resolutionDate = marker["resolution_date"];
      return Marker(
        marker["id"],
        point["y"] as double,
        point["x"] as double,
        MarkerType.values.firstWhereOrNull((type) => type.id == marker["marker_types_id"]) ??
            MarkerType.unknown,
        DateTime.parse(marker["creation_date"]),
        (resolutionDate as String?).map(DateTime.parse),
        marker["created_by"],
        marker["solved_by"],
        true, // TODO obtain "can be reported" field
      );
    });
  }

  Future<void> resolveMarker(int markerId) {
    return _postAuthenticated("/map/resolve/$markerId");
  }

  Future<AuthenticatedUser> getAuthenticatedUser() {
    return _getJsonAuthenticated("/user").map((u) => AuthenticatedUser(u["name"], u["points"]));
  }

  Future<User> getUser(int userId) {
    return _getJson("/user/$userId").map((u) => User(u["name"], u["points"]));
  }

  Future<void> reportAsInappropriate(int markerId) {
    // TODO insert real path
    return _postAuthenticated("/map/report/$markerId");
  }

  Future<void> suggestPill(String text, String source) {
    return _postAuthenticated("/pills/add", fields: {"text": text, "source": source});
  }
}
