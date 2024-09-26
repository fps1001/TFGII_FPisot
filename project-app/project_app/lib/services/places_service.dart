import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesService {
  final Dio _dio = Dio();
  final String _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  // Constructor
  PlacesService();

  // Método para buscar un lugar por su nombre y ciudad
  Future<Map<String, dynamic>?> searchPlace(String placeName, String city) async {
    const String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json';

    try {
      // Incluimos tanto el nombre del lugar como la ciudad en el query
      final response = await _dio.get(url, queryParameters: {
        'query': '$placeName, $city',  // Añadir la ciudad a la búsqueda
        'key': _apiKey,
        'language': 'es',
      });

      if (response.statusCode == 200 && response.data['results'] != null && response.data['results'].isNotEmpty) {
        final result = response.data['results'][0];
        return {
          'name': result['name'],
          'location': result['geometry']['location'],
          'rating': result['rating'],
          'photos': result['photos'],
          'displayName': result['name'],
          'editorialSummary': result['editorial_summary'],
          'websiteUri': result['website'],
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en la búsqueda del lugar: $e');
      }
    }
    return null;
  }
}
