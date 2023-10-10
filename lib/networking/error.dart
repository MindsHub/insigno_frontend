import 'package:http/http.dart';

Future<void> _throwErrors<T extends BaseResponse>(T baseResponse) async {
  if (baseResponse.statusCode < 400) {
    return;
  }

  Response? response;
  if (baseResponse is StreamedResponse) {
    response = await Response.fromStream(baseResponse);
  } else if (baseResponse is Response) {
    response = baseResponse;
  }

  String? reason = response?.body;
  if (reason == null || reason.isEmpty || reason.startsWith("<!DOCTYPE html>")) {
    reason = baseResponse.reasonPhrase;
  }

  if (baseResponse.statusCode == 401 || baseResponse.statusCode == 403) {
    throw UnauthorizedException(baseResponse.statusCode, reason);
  } else if (baseResponse.statusCode == 404) {
    throw NotFoundException(baseResponse.statusCode, reason);
  } else if (baseResponse.statusCode < 500) {
    throw BadRequestException(baseResponse.statusCode, reason);
  } else {
    throw InternalServerErrorException(baseResponse.statusCode, reason);
  }
}

extension ThrowErrorsExtension<T extends BaseResponse> on T {
  Future<T> throwErrors() async {
    await _throwErrors(this);
    return this;
  }
}

extension ThrowErrorsFutureExtension<T extends BaseResponse> on Future<T> {
  Future<T> throwErrors() async {
    var response = await this;
    await _throwErrors(response);
    return response;
  }
}

abstract class HttpException implements Exception {
  final int statusCode;
  final String response;

  HttpException(this.statusCode, this.response);

  @override
  String toString() {
    return "$statusCode $response";
  }
}

class UnauthorizedException extends HttpException {
  UnauthorizedException(int statusCode, String? reason)
      : super(statusCode, reason ?? "Unauthorized");
}

class NotFoundException extends HttpException {
  NotFoundException(int statusCode, String? reason) : super(statusCode, reason ?? "Not found");
}

class BadRequestException extends HttpException {
  BadRequestException(int statusCode, String? reason) : super(statusCode, reason ?? "Bad request");
}

class InternalServerErrorException extends HttpException {
  InternalServerErrorException(int statusCode, String? reason)
      : super(statusCode, reason ?? "Internal server error");
}
