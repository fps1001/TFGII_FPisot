import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_app/widgets/widgets.dart';

class MapView extends StatelessWidget {
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

  MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco City Tour'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter:
                  LatLng(41.3833, 2.1750), // Set the initial map center
              initialZoom: 15.0, // Set the initial zoom level
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: markers.map((map) {
                  return Marker(
                    point: LatLng(
                      double.parse(map['coordenadas_gps'].split(',')[0]),
                      double.parse(map['coordenadas_gps'].split(',')[1]),
                    ),
                    child: CustomMarker(
                        nombre: map['nombre'], descripcion: map['descripción']),
                  );
                }).toList(),
              )
            ],
          ),
        ],
      ),
    );
  }
}
