import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger para registrar errores

class PlacesService {
  final Dio _dio = Dio();
  final String _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  // Constructor
  PlacesService();

  // Método para buscar un lugar por su nombre y ciudad
  Future<Map<String, dynamic>?> searchPlace(
      String placeName, String city) async {
    const String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json';

    // Si no hay clave API, registramos el error
    if (_apiKey.isEmpty) {
      log.e('PlacesService: No se encontró la clave API de Google Places');
      return null;
    }

    try {
      log.i('PlacesService: Buscando "$placeName" en la ciudad $city');

      // Incluimos tanto el nombre del lugar como la ciudad en el query
      final response = await _dio.get(url, queryParameters: {
        'query': '$placeName, $city', // Añadir la ciudad a la búsqueda
        'key': _apiKey,
        'language': 'es',
      });

      if (response.statusCode == 200 &&
          response.data['results'] != null &&
          response.data['results'].isNotEmpty) {
        final result =
            response.data['results'][0]; // Tomamos el primer resultado

        log.i('PlacesService: Lugar encontrado: ${result['name']} en $city');

        // Mapeamos todos los campos relevantes del lugar
        return {
          'name': result['name'], // Nombre del lugar
          'location': result['geometry']['location'], // Coordenadas
          'formatted_address':
              result['formatted_address'], // Dirección completa
          'rating': result['rating'], // Puntuación
          'user_ratings_total':
              result['user_ratings_total'], // Total de reseñas
          'photos': result['photos'], // Fotos del lugar
          'website': result['website'], // Sitio web del lugar
        };
      }
    } catch (e, stackTrace) {
      log.e('PlacesService: Error durante la búsqueda del lugar "$placeName"',
          error: e, stackTrace: stackTrace);
      if (kDebugMode) {
        print('Error en la búsqueda del lugar: $e');
      }
    }
    return null;
  }
}
