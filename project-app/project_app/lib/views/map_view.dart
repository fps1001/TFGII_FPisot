import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../blocs/blocs.dart';
import '../themes/themes.dart';

class MapView extends StatelessWidget {
  final LatLng initialPosition;
  final Set<Polyline> polylines;
  final Set<Marker> markers;


  MapView({
    Key? key, 
    required this.initialPosition, 
    required this.polylines, 
    required this.markers
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla
    // TODO hay que restar el tamaño del appbar
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
            compassEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            mapToolbarEnabled: false,

            // vamos a lanzar un evento cuando el mapa se haya creado para obtener el controlador del mapa.
            onMapCreated: (controller) =>
                mapBloc.add(OnMapInitializedEvent(controller)),
            style: jsonEncode(appleMapEsqueMapTheme),

            polylines: polylines,
            markers: markers,
            // Se utiliza para no generar tantas peticiones al mover el mapa.
            onCameraMove: (position) => mapBloc.mapCenter = position.target,

          ),
        ));
  }
}
