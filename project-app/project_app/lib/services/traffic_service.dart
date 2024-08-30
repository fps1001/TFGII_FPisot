import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/exceptions/exceptions.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/services.dart';

class TrafficService {
  final Dio _dioTraffic;
  final Dio _dioPlaces;

  final String _baseTrafficUrl = 'https://api.mapbox.com/directions/v5/mapbox';
  final String _basePlacesUrl =
      'https://api.mapbox.com/geocoding/v5/mapbox.places';

  TrafficService()
      : _dioTraffic = Dio()..interceptors.add(TrafficInterceptor()),
        _dioPlaces = Dio()..interceptors.add(PlacesInterceptor());

  Future<TrafficResponse> getCoorsStartToEnd(LatLng start, LatLng end) async {
    final coorsString =
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
    final url = '$_baseTrafficUrl/walking/$coorsString';

    try {
      final resp = await _dioTraffic.get(url);

      if (resp.data == null ||
          resp.data['routes'] == null ||
          resp.data['routes'].isEmpty) {
        throw AppException("No routes found in response", url: url);
      }

      final data = TrafficResponse.fromJson(resp.data);
      return data;
    } on DioException catch (e) {
      throw DioExceptions.handleDioError(e, url: url);
    } catch (e) {
      throw AppException("An unknown error occurred", url: url);
    }
  }

  //Devuelve el listado de sitios de las busquedas, pasandole la coordenada que funcionará de proximidad de petición.
  Future<List<Feature>> getResultsByQuery(
      LatLng proximity, String query) async {
    if (query.isEmpty) {
      return [];
    }
    final url = '$_basePlacesUrl/$query.json';

    final resp = await _dioPlaces.get(url, queryParameters: {
      'proximity': '${proximity.longitude}, ${proximity.latitude}'
    });

    final placesResponse = PlacesResponse.fromJson(resp.data);
    return placesResponse.features; // lugares en mapbox se llaman Features.
  }
}
