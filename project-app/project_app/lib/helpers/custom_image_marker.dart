import 'package:dio/dio.dart';
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
  final resizedData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
  
  if (resizedData == null) {
    // Maneja el error de carga
    return BitmapDescriptor.defaultMarker;
  }
  
  return BitmapDescriptor.bytes(resizedData.buffer.asUint8List());
}

Future<BitmapDescriptor> getNetworkImageMarker() async {
  final resp = await Dio().get(
      'https://cdn4.iconfinder.com/data/icons/small-n-flat/24/map-marker-512.png',
      options: Options(responseType: ResponseType.bytes));

  
  // Cambiar tamaño de la imagen
  final imageCodec = await ui.instantiateImageCodec(resp.data, targetHeight: 50, targetWidth: 50);
  final frameInfo = await imageCodec.getNextFrame();
  final data = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

  // Si no encuentra la imagen devuelve un marcador por defecto.
  if (data == null) return getCustomMarker();

  return BitmapDescriptor.bytes(data.buffer.asUint8List());
}
