import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

class MapView extends StatelessWidget {
  final LatLng initialPosition;
  final LatLng? userLocation; // Nueva propiedad para la ubicación del usuario

  final List<Map<String, dynamic>> markers = [
    {
      "nombre": "Casco Histórico de Salamanca",
      "coordenadas_gps": (40.9709, -5.6681),
      "breve_descripcion":
          "El casco histórico de Salamanca es un conjunto de edificios y calles que datan del siglo XIX.",
      "url": "https://www.salamanca.es/visitar/casco-historico"
    },
    {
      "nombre": "Río Tormes",
      "coordenadas_gps": (40.9709, -5.6681),
      "breve_descripcion":
          "El río Tormes es un afluente del Duero y discurre por el centro de la ciudad.",
      "url": ""
    },
    {
      "nombre": "Jardines de San Esteban",
      "coordenadas_gps": (40.9709, -5.6681),
      "breve_descripcion":
          "Los Jardines de San Esteban son un parque público ubicado en el corazón de la ciudad.",
      "url": ""
    }
  ];

  MapView({super.key, required this.initialPosition, this.userLocation});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return const Placeholder();
  }
}
