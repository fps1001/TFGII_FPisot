import 'app_exception.dart';
import 'package:dio/dio.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger

class DioExceptions {
  static AppException handleDioError(DioException error, {String? url}) {
    // Log del error recibido por Dio antes de procesarlo
    log.e(
        'DioExceptions: Error de tipo ${error.type}, mensaje: ${error.message}, URL: $url');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return FetchDataException("Tiempo de conexión agotado", url: url);
      case DioExceptionType.sendTimeout:
        return FetchDataException("Tiempo de envío agotado", url: url);
      case DioExceptionType.receiveTimeout:
        return FetchDataException("Tiempo de recepción agotado", url: url);
      case DioExceptionType.badResponse:
        return _handleHttpResponseError(error, url: url);
      case DioExceptionType.cancel:
        return AppException("La solicitud al servidor fue cancelada", url: url);
      case DioExceptionType.unknown:
        return FetchDataException("Sin conexión a Internet", url: url);
      default:
        return AppException("Ocurrió un error inesperado", url: url);
    }
  }

  static AppException _handleHttpResponseError(DioException error,
      {String? url}) {
    int? statusCode = error.response?.statusCode;

    // Log del estado HTTP y la URL en caso de error de respuesta
    log.e('DioExceptions: Error HTTP $statusCode para la URL: $url');

    switch (statusCode) {
      case 400:
        return BadRequestException("Solicitud incorrecta", url: url);
      case 401:
        return UnauthorizedException("No autorizado", url: url);
      case 403:
        return AppException("Prohibido", url: url);
      case 404:
        return AppException("Recurso no encontrado", url: url);
      case 500:
        return AppException("Error interno del servidor", url: url);
      default:
        return AppException("Código de estado inválido recibido: $statusCode",
            url: url);
    }
  }
}
