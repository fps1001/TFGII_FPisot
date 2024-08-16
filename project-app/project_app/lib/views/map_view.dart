import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../blocs/blocs.dart';
import '../themes/themes.dart';


class MapView extends StatelessWidget {
  final LatLng initialPosition;

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

  MapView({super.key, 
  required this.initialPosition});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla
    final size = MediaQuery.of(context).size;

    final mapBloc = BlocProvider.of<MapBloc>(context);

    final CameraPosition initialCameraPosition = CameraPosition(        
      target: initialPosition,
      zoom: 15
    );

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
          onMapCreated: ( controller ) => mapBloc.add(OnMapInitializedEvent(controller)),
          style: jsonEncode(appleMapEsqueMapTheme),
          //TODO: markers: 
          //TODO: rutas
        ),
      )
    );
  }
}
