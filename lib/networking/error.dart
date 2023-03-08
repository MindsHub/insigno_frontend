import 'package:http/http.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void _throwErrors<T extends BaseResponse>(final T response) {
  if (response.statusCode < 400) {
    return;
  } else if (response.statusCode == 401 || response.statusCode == 403) {
    throw UnauthorizedException(response.statusCode, response.reasonPhrase);
  } else if (response.statusCode == 404) {
    throw NotFoundException(response.statusCode, response.reasonPhrase);
  } else if (response.statusCode < 500) {
    throw BadRequestException(response.statusCode, response.reasonPhrase);
  } else {
    throw InternalServerErrorException(response.statusCode, response.reasonPhrase);
  }
}

extension ThrowErrorsExtension<T extends BaseResponse> on T {
  T throwErrors() {
    _throwErrors(this);
    return this;
  }
}

extension ThrowErrorsFutureExtension<T extends BaseResponse> on Future<T> {
  Future<T> throwErrors() async {
    var response = await this;
    _throwErrors(response);
    return response;
  }
}

abstract class HttpException implements Exception {
  final int statusCode;
  final String prefix;

  HttpException(this.statusCode, this.prefix);

  @override
  String toString() {
    return "$statusCode $prefix";
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
