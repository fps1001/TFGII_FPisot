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
        final result = response.data['results'][0];  // Tomamos el primer resultado

        // Mapeamos todos los campos relevantes del lugar
        return {
          'name': result['name'],  // Nombre del lugar
          'location': result['geometry']['location'],  // Coordenadas
          'formatted_address': result['formatted_address'],  // Dirección completa
          'rating': result['rating'],  // Puntuación
          'user_ratings_total': result['user_ratings_total'],  // Total de reseñas
          'photos': result['photos'],  // Fotos del lugar
          //'place_id': result['place_id'],  // ID del lugar
          //'plus_code': result['plus_code']?['global_code'],  // Código Plus
          //'business_status': result['business_status'],  // Estado comercial
          //'icon': result['icon'],  // Icono del lugar
          //'types': result['types'],  // Tipos de lugar
          //'opening_hours': result['opening_hours']?['open_now'],  // Si está abierto ahora
          'website': result['website'],  // Sitio web del lugar
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
