import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger

Future<BitmapDescriptor> getCustomMarker() async {
  try {
    final ByteData data =
        await rootBundle.load('assets/location_troll_bg2.png');
    final ui.Codec imageCodec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: 62,
      targetWidth: 45,
    );
    final ui.FrameInfo frameInfo = await imageCodec.getNextFrame();
    final ByteData? resizedData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

    if (resizedData == null) {
      log.e('getCustomMarker: Error al convertir la imagen a bytes.');
      return BitmapDescriptor.defaultMarker;
    }

    log.d('getCustomMarker: Marcador personalizado creado con éxito.');
    return BitmapDescriptor.bytes(resizedData.buffer.asUint8List());
  } catch (e, stackTrace) {
    log.e('getCustomMarker: Error al cargar el marcador personalizado',
        error: e, stackTrace: stackTrace);
    return BitmapDescriptor.defaultMarker;
  }
}

Future<BitmapDescriptor> getNetworkImageMarker(String imageUrl) async {
  try {
    Uri uri = Uri.parse(imageUrl);
    if (!uri.isAbsolute) {
      log.w(
          'getNetworkImageMarker: URL inválida, usando marcador predeterminado.');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }

    final response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));
    if (response.statusCode != 200 || response.data == null) {
      log.e(
          'getNetworkImageMarker: Fallo al descargar imagen, usando marcador predeterminado.');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }

    final codec = await ui.instantiateImageCodec(response.data,
        targetHeight: 40, targetWidth: 40);
    final frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    final markerBytes = await _createCircularImageWithBorder(image);
    log.d(
        'getNetworkImageMarker: Marcador con imagen de red creado con éxito.');
    return BitmapDescriptor.bytes(markerBytes);
  } catch (e, stackTrace) {
    log.e('getNetworkImageMarker: Error al cargar imagen desde la red',
        error: e, stackTrace: stackTrace);
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }
}

Future<Uint8List> _createCircularImageWithBorder(ui.Image image,
    {Color borderColor = Colors.green, double borderWidth = 4}) async {
  final double imageSize = image.width.toDouble();
  final double size = imageSize + borderWidth * 2;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final center = Offset(size / 2, size / 2);
  final radius = imageSize / 2;

  final Paint borderPaint = Paint()
    ..color = borderColor
    ..style = PaintingStyle.fill;

  canvas.drawCircle(center, radius + borderWidth, borderPaint);

  final Rect imageRect = Rect.fromCircle(center: center, radius: radius);
  canvas.clipPath(Path()..addOval(imageRect));
  canvas.drawImage(image, imageRect.topLeft, Paint());

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

  log.d('getCustomMarker: Imagen circular con borde creada con éxito.');
  return byteData!.buffer.asUint8List();
}
