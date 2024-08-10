import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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

    return SizedBox(
      width: size.width,
      height: size.height,
      child: FlutterMap(
        options: MapOptions(
          // Centrar en la ubicación del usuario si está disponible
          initialCenter: userLocation ?? initialPosition,
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(
            markers: [
              ...markers.map((map) {
                final (latitude, longitude) = map['coordenadas_gps'] as (double, double);
                return Marker(
                  point: LatLng(latitude, longitude),
                  child: const Icon(Icons.location_pin, color: Colors.blueAccent),
                );
              }),
              // Añadir el marcador de la ubicación del usuario
              if (userLocation != null)
                Marker(
                  point: userLocation!,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
            ],
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () =>
                    launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
