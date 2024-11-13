import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_app/logger/logger.dart';

class PlacesService {
  final Dio _dio;
  final String _apiKey;

  // Constructor que acepta un Dio opcional
  PlacesService({Dio? dio})
      : _dio = dio ?? Dio(),
        _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  Future<Map<String, dynamic>?> searchPlace(String placeName, String city) async {
    const String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json';

    if (_apiKey.isEmpty) {
      log.e('PlacesService: No se encontró la clave API de Google Places');
      return null;
    }

    try {
      log.i('PlacesService: Buscando "$placeName" en la ciudad $city');

      final response = await _dio.get(url, queryParameters: {
        'query': '$placeName, $city',
        'key': _apiKey,
        'language': 'es',
      });

      if (response.statusCode == 200 &&
          response.data['results'] != null &&
          response.data['results'].isNotEmpty) {
        final result = response.data['results'][0];

        log.i('PlacesService: Lugar encontrado: ${result['name']} en $city');
        return {
          'name': result['name'],
          'location': result['geometry']['location'],
          'formatted_address': result['formatted_address'],
          'rating': result['rating'],
          'user_ratings_total': result['user_ratings_total'],
          'photos': result['photos'],
          'website': result['website'],
        };
      }
    } catch (e, stackTrace) {
      log.e('PlacesService: Error durante la búsqueda del lugar "$placeName"', error: e, stackTrace: stackTrace);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> searchPlaces(String query, String city) async {
    const String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json';

    if (_apiKey.isEmpty) {
      log.e('PlacesService: No se encontró la clave API de Google Places');
      return [];
    }

    try {
      log.i('PlacesService: Buscando lugares para "$query" en la ciudad $city');

      final response = await _dio.get(url, queryParameters: {
        'query': '$query, $city',
        'key': _apiKey,
        'language': 'es',
      });

      if (response.statusCode == 200 && response.data['results'] != null && response.data['results'].isNotEmpty) {
        final results = response.data['results'] as List;

        return results.map((result) {
          return {
            'name': result['name'],
            'location': result['geometry']['location'],
            'formatted_address': result['formatted_address'],
            'rating': result['rating'],
            'user_ratings_total': result['user_ratings_total'],
            'photos': result['photos'],
            'website': result['website'],
          };
        }).toList();
      }
    } catch (e, stackTrace) {
      log.e('PlacesService: Error durante la búsqueda de lugares "$query"', error: e, stackTrace: stackTrace);
    }
    return [];
  }
}
