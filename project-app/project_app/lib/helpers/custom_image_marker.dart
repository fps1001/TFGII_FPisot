import 'package:dio/dio.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getNetworkImageMarker() async {
  final resp = await Dio().get(
      'https://cdn4.iconfinder.com/data/icons/small-n-flat/24/map-marker-512.png',
      options: Options(responseType: ResponseType.bytes));

  

  final imageCodec = await ui.instantiateImageCodec(resp.data, targetHeight: 150, targetWidth: 150);

  final frameInfo = await imageCodec.getNextFrame();

  final data = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

  //if (data == null) return null; //todo cargar una imagen por defecto en assets.

  return BitmapDescriptor.bytes(data!.buffer.asUint8List());
}
