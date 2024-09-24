import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesService {
  final Dio _dio = Dio();
  final String _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  // Constructor
  PlacesService();

  // Método para buscar un lugar por su nombre
  Future<Map<String, dynamic>?> searchPlace(String query) async {
    const String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json';

    try {
      final response = await _dio.get(url, queryParameters: {
        'query': query,
        'key': _apiKey,
        'language': 'es',
      });

      if (response.statusCode == 200) {
        return response.data['results']?.isNotEmpty == true
            ? response.data['results'][0]
            : null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en la búsqueda del lugar: $e');
      }
    }

    return null;
  }
}
