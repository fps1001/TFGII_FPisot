import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../blocs/blocs.dart';
import '../themes/themes.dart';

class MapView extends StatelessWidget {
  final LatLng initialPosition;
  final Set<Polyline> polylines;

final List<Map<String, Marker>> markers = [
  {
    "nombre": Marker(
      markerId: const MarkerId("Casco Histórico de Salamanca"),
      position: const LatLng(40.9709, -5.6681),
      infoWindow: const InfoWindow(
        title: "Casco Histórico de Salamanca",
        snippet:
            "El casco histórico de Salamanca es un conjunto de edificios y calles que datan del siglo XIX.",
      ),
      onTap: () {
        // Acción cuando se toca el marcador
      },
    ),
  },
  {
    "nombre": Marker(
      markerId: const MarkerId("Río Tormes"),
      position: const LatLng(40.9709, -5.6681),
      infoWindow: const InfoWindow(
        title: "Río Tormes",
        snippet:
            "El río Tormes es un afluente del Duero y discurre por el centro de la ciudad.",
      ),
      onTap: () {
        // Acción cuando se toca el marcador
      },
    ),
  },
  {
    "nombre": Marker(
      markerId: const MarkerId("Jardines de San Esteban"),
      position: const LatLng(40.9709, -5.6681),
      infoWindow: const InfoWindow(
        title: "Jardines de San Esteban",
        snippet:
            "Los Jardines de San Esteban son un parque público ubicado en el corazón de la ciudad.",
      ),
      onTap: () {
        // Acción cuando se toca el marcador
      },
    ),
  },
];


  MapView({
    super.key, 
    required this.initialPosition, 
    required this.polylines});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla
    final size = MediaQuery.of(context).size;

    final mapBloc = BlocProvider.of<MapBloc>(context);

    final CameraPosition initialCameraPosition =
        CameraPosition(target: initialPosition, zoom: 15);

    return SizedBox(
        width: size.width,
        height: size.height,
        //Se añade un listener para saber si el mapa se ha movido y lanzar un evento.
        child: Listener(
          // Deja de seguir al usuario al mover el mapa.
          onPointerMove: (event) => mapBloc.add(OnStopFollowingUserEvent()),
          child: GoogleMap(
            initialCameraPosition: initialCameraPosition,
            compassEnabled: true,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            // vamos a lanzar un evento cuando el mapa se haya creado para obtener el controlador del mapa.
            onMapCreated: (controller) =>
                mapBloc.add(OnMapInitializedEvent(controller)),
            style: jsonEncode(appleMapEsqueMapTheme),

            polylines: polylines,
            markers: markers.map((map) => map.values.first).toSet(),
            // Se utiliza para no generar tantas peticiones al mover el mapa.
            onCameraMove: (position) => mapBloc.mapCenter = position.target,

          ),
        ));
  }
}
