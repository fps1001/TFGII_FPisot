// lib/exceptions/dio_exceptions.dart
import 'app_exception.dart';
import 'package:dio/dio.dart';

class DioExceptions {
  static AppException handleDioError(DioException error, {String? url}) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return FetchDataException("Connection timed out", url: url);
      case DioExceptionType.sendTimeout:
        return FetchDataException("Send request timed out", url: url);
      case DioExceptionType.receiveTimeout:
        return FetchDataException("Receive response timed out", url: url);
      case DioExceptionType.badResponse:
        return _handleHttpResponseError(error, url: url);
      case DioExceptionType.cancel:
        return AppException("Request to the server was cancelled", url: url);
      case DioExceptionType.unknown:
        return FetchDataException("No Internet connection", url: url);
      default:
        return AppException("Unexpected error occurred", url: url);
    }
  }

  static AppException _handleHttpResponseError(DioException error,
      {String? url}) {
    int? statusCode = error.response?.statusCode;
    switch (statusCode) {
      case 400:
        return BadRequestException("Bad request", url: url);
      case 401:
        return UnauthorizedException("Unauthorized", url: url);
      case 403:
        return AppException("Forbidden", url: url);
      case 404:
        return AppException("Resource not found", url: url);
      case 500:
        return AppException("Internal server error", url: url);
      default:
        return AppException("Received invalid status code: $statusCode",
            url: url);
    }
  }
}
