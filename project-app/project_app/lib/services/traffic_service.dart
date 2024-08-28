import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/services.dart';

class TrafficService {
  final Dio _dioTraffic;
  final Dio _dioPlaces;

  final String _baseTrafficUrl =
      'https://api.mapbox.com/directions/v5/mapbox/walking/';
  final String _basePlacesUrl =
      'https://api.mapbox.com/search/searchbox/v1/suggest';

  TrafficService()
      : _dioTraffic = Dio()..interceptors.add(TrafficInterceptor()),
        _dioPlaces = Dio()..interceptors.add(PlacesInterceptor());

  Future<TrafficResponse> getCoorsStartToEnd(LatLng start, LatLng end) async {
    final coorsString =
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
    final url = '$_baseTrafficUrl/driving/$coorsString';
    print(url);
    // TODO Configurar para mandar tokens y completar petición.
    // Uso interceptores de Dio: intercepta cada petición que va a salir de http:

    final resp = await _dioTraffic.get(url);

    final data = TrafficResponse.fromJson(resp.data);

    // Ya devuelve las rutas, por ejemplo para acceder a la primera (siempre habrá una posibilidad: data.routes[0].distance o .geometry etc)
    return data;
  }

  Future getResultByQuery(LatLng proximity, String query) async {
    if (query.isEmpty) return [];

    final url = '$_basePlacesUrl?q=';

    final resp = await _dioTraffic.get(url, queryParameters: {
      'proximity': '${proximity.longitude},${proximity.latitude}'
    });
    // De la respuesta hay que obtener el modelo.

    final placesResponse = PlacesResponse.fromJson(resp.data);

    return;
    // placesResponse.features; // Lugares => Features
  }
}
