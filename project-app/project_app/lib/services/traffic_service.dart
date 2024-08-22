import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrafficService {
  final Dio _dioTraffic;
  final String _baseTrafficUrl = 'https://api.mapbox.com/directions/v5/mapbox';

  TrafficService() : _dioTraffic = Dio(); // TODO configurar interceptors

  Future getCoorsStartToEnd(LatLng start, LatLng end) async {
    final coorsString =
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
    final url = '$_baseTrafficUrl/driving/$coorsString';

    // TODO Configurar para mandar tokens y completar petición.
  // Uso interceptores de Dio: intercepta cada petición que va a salir de http: 

    final resp = await _dioTraffic.get(url);

    return resp.data;
  }
}
