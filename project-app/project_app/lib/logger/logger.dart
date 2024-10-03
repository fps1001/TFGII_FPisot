// logger.dart

import 'package:logger/logger.dart';

final Logger log = Logger(
  printer: PrettyPrinter(
    methodCount:
        0, // Muestra 2 niveles por defecto, lo dejo a 0 para compactar.
    errorMethodCount: 8, // Muestra hasta 8 niveles en caso de error
    lineLength: 120,
    colors: true,
    printEmojis: true,
    //dateTimeFormat: DateTimeFormat.onlyTime,
    dateTimeFormat: DateTimeFormat.none,
  ),
);
