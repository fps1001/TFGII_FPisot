import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart'; // Para cargar assets

Future<BitmapDescriptor> getCustomMarker() async {
  // Cargar la imagen desde el asset
  final ByteData data = await rootBundle.load('assets/location_troll_bg.png');

  // Convertir la imagen a formato de bytes y redimensionarla
  final imageCodec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
    targetHeight: 40, // Cambia estos valores según el tamaño que necesites
    targetWidth: 40,
  );

  final frameInfo = await imageCodec.getNextFrame();
  final resizedData =
      await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

  if (resizedData == null) {
    // Maneja el error de carga
    return BitmapDescriptor.defaultMarker;
  }

  return BitmapDescriptor.bytes(resizedData.buffer.asUint8List());
}

Future<BitmapDescriptor> getNetworkImageMarker(String imageUrl) async {
  try {
    // Verificar si la URL es válida
    Uri uri = Uri.parse(imageUrl);
    if (!uri.isAbsolute) {
      if (kDebugMode) {
        print('Invalid image URL, using default marker.');
      }
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }

    // Descargar la imagen
    final response = await Dio().get(imageUrl, options: Options(responseType: ResponseType.bytes));
    if (response.statusCode != 200 || response.data == null) {
      if (kDebugMode) {
        print('Failed to load image, using default marker.');
      }
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }

    // Crear la imagen redimensionada con tamaño de 80x80
    final codec = await ui.instantiateImageCodec(
      response.data,
      targetHeight: 40, 
      targetWidth: 40,
    );
    final frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    // Convertir la imagen a un círculo con un borde verde
    final Uint8List markerBytes = await _createCircularImageWithBorder(image, borderColor: Colors.green, borderWidth: 4);

    return BitmapDescriptor.bytes(markerBytes);
  } catch (e) {
    if (kDebugMode) {
      print('Error loading image from network: $e');
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }
}

Future<Uint8List> _createCircularImageWithBorder(ui.Image image, {Color borderColor = Colors.green, double borderWidth = 4}) async {
  // Calcular el tamaño total del marcador (imagen + borde)
  final double imageSize = image.width.toDouble();
  final double size = imageSize + borderWidth * 2;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Definir el centro y el radio del círculo
  final center = Offset(size / 2, size / 2);
  final radius = imageSize / 2;

  // Dibujar el fondo del borde verde
  final Paint borderPaint = Paint()
    ..color = borderColor
    ..style = PaintingStyle.fill;

  canvas.drawCircle(center, radius + borderWidth, borderPaint);

  // Dibujar la imagen circular
  final Rect imageRect = Rect.fromCircle(center: center, radius: radius);
  canvas.clipPath(Path()..addOval(imageRect));
  canvas.drawImage(image, imageRect.topLeft, Paint());

  // Convertir a bytes la imagen final con el borde
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
