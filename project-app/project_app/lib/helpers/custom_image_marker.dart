import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart'; // Para cargar assets

Future<BitmapDescriptor> getCustomMarker() async {
  // Cargar la imagen desde el asset
  final ByteData data = await rootBundle.load('assets/custompin.png');

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
    // Realiza la petición HTTP para obtener la imagen de la URL proporcionada
    final resp = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));

    // Redimensiona la imagen descargada
    final imageCodec = await ui.instantiateImageCodec(
      resp.data,
      targetHeight: 50,
      targetWidth: 50,
    );
    final frameInfo = await imageCodec.getNextFrame();
    final data =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

    // Si la imagen no puede ser cargada, devuelve el marcador azure por defecto
    if (data == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }

    return BitmapDescriptor.bytes(data.buffer.asUint8List());
  } catch (e) {
    // Si hay algún error en la carga de la imagen, devolver un marcador azure
    if (kDebugMode) {
      print('Error loading image from network: $e');
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }
}
