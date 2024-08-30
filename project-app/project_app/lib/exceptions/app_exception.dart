class AppException implements Exception {
  final String message;
  final String? prefix;
  final String? url;

  AppException(this.message, {this.prefix, this.url});

  @override
  String toString() {
    return "$prefix$message${url != null ? ' (URL: $url)' : ''}";
  }
}

class FetchDataException extends AppException {
  FetchDataException(super.message, {super.url})
      : super(prefix: "Error during communication: ");
}

class BadRequestException extends AppException {
  BadRequestException(super.message, {super.url})
      : super(prefix: "Invalid Request: ");
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message, {super.url})
      : super(prefix: "Unauthorized: ");
}

class InvalidInputException extends AppException {
  InvalidInputException(super.message, {super.url})
      : super(prefix: "Invalid Input: ");
}
