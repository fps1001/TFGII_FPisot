import 'package:project_app/logger/logger.dart'; // Importar logger para registrar errores

class AppException implements Exception {
  final String message;
  final String? prefix;
  final String? url;

  AppException(this.message, {this.prefix, this.url}) {
    log.e('$prefix$message${url != null ? ' (URL: $url)' : ''}');
  }

  @override
  String toString() {
    return "$prefix$message${url != null ? ' (URL: $url)' : ''}";
  }
}

class FetchDataException extends AppException {
  FetchDataException(super.message, {super.url})
      : super(prefix: "Error en la comunicación: ");
}

class BadRequestException extends AppException {
  BadRequestException(super.message, {super.url})
      : super(prefix: "Solicitud incorrecta: ");
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message, {super.url})
      : super(prefix: "No autorizado: ");
}

class InvalidInputException extends AppException {
  InvalidInputException(super.message, {super.url})
      : super(prefix: "Entrada no válida: ");
}
