import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  final String name;
  final LatLng location;
  final String? imageUrl;

  Place({
    required this.name,
    required this.location,
    this.imageUrl,
  });

  // Método de fábrica para crear un `Place` desde los datos JSON de la API de Google Places
  factory Place.fromJson(Map<String, dynamic> json) {
    final lat = json['geometry']['location']['lat'];
    final lng = json['geometry']['location']['lng'];
    final LatLng location = LatLng(lat, lng);

    // Obtiene la API key de Google Places desde el archivo .env
    String apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception("Google Places API Key not found");
    }

    // Si hay fotos disponibles, construir la URL de la primera foto
    String? imageUrl;
    if (json['photos'] != null && json['photos'].isNotEmpty) {
      final photoReference = json['photos'][0]['photo_reference'];
      imageUrl = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';
    }

    return Place(
      name: json['name'],
      location: location,
      imageUrl: imageUrl,
    );
  }
}
