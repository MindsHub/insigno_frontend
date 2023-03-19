import 'dart:convert';

import 'package:http/http.dart';

extension FutureMap<T> on Future<T> {
  Future<R> map<R>(R Function(T) f) async {
    final T t = await this;
    final R r = f(t);
    return r;
  }
}

extension JsonResponse on Response {
  dynamic mapParseJson() async {
    return jsonDecode(utf8.decode(bodyBytes));
  }
}

extension FutureResponse on Future<Response> {
  Future<dynamic> mapParseJson() async {
    return map((response) => response.mapParseJson());
  }
}

extension FutureStreamedResponse on Future<StreamedResponse> {
  Future<dynamic> mapParseJson() async {
    final resp = await this;
    final body = await resp.stream.bytesToString(utf8);
    return jsonDecode(body);
  }
}
