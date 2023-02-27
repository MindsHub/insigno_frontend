import 'dart:convert';

import 'package:http/http.dart';

extension FutureMap<T> on Future<T> {
  Future<R> map<R>(R Function(T) f) async {
    final T t = await this;
    final R r = f(t);
    return r;
  }
}

extension FutureResponse on Future<Response> {
  Future<dynamic> mapParseJson() async {
    return map((response) => jsonDecode(utf8.decode(response.bodyBytes)));
  }
}