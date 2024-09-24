import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_app/models/place.dart';

class PlacesService {
  final Dio _dio = Dio();
  final String _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  // Constructor
  PlacesService();

  // Método para buscar lugares por nombre
  Future<List<Place>?> searchPlace(String query) async {
    const String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json';

    try {
      final response = await _dio.get(url, queryParameters: {
        'query': query,
        'key': _apiKey,
      });

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        // Convertir cada resultado en un objeto `Place`
        return results.map((json) => Place.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en la búsqueda de lugares: $e');
      }
    }

    return null;
  }
}
