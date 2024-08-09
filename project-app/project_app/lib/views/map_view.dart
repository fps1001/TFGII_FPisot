import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapView extends StatelessWidget {
  final LatLng initialPosition;
  final LatLng? userLocation; // Nueva propiedad para la ubicación del usuario

  final List<Map<String, dynamic>> markers = [
    {
      "nombre": "Parque de Collserola",
      "coordenadas_gps": "41.4035, 2.1325",
      "descripción":
          "Un parque natural que ofrece vistas panorámicas de la ciudad y es un refugio para la biodiversidad",
      "url": ""
    },
    {
      "nombre": "Barrio Gótico de Barcelona",
      "coordenadas_gps": "41.3833, 2.1750",
      "descripción":
          "Un barrio histórico y emblemático de la ciudad, conocido por sus calles empedradas, iglesias y monumentos medievales",
      "url": ""
    },
    {
      "nombre": "Parque de la Ciutadella",
      "coordenadas_gps": "41.3867, 2.1733",
      "descripción":
          "Un parque urbano que fue un antiguo recinto militar y ahora es un espacio verde y recreativo para la ciudadanía",
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
                return Marker(
                  point: LatLng(
                    double.parse(map['coordenadas_gps'].split(',')[0]),
                    double.parse(map['coordenadas_gps'].split(',')[1]),
                  ),
                  child:
                      const Icon(Icons.location_pin, color: Colors.limeAccent),
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