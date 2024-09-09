import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs/blocs.dart';


class BtnTest extends StatelessWidget {
  const BtnTest({super.key});

  @override
  Widget build(BuildContext context) {
    // Coordenadas de prueba para Salamanca, España (centro)
    final List<LatLng> salamancaCoordinates = [
      LatLng(40.964165, -5.663774), // Plaza Mayor
      LatLng(40.962903, -5.666918), // Catedral de Salamanca
      LatLng(40.965479, -5.668760), // Casa de las Conchas
      LatLng(40.963776, -5.669952), // Universidad de Salamanca
    ];
    // Para obtener la polilínea optimizada de puntos.
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    // Para pintar línea
    final mapBloc = BlocProvider.of<MapBloc>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      // Botón de centrado en la ubicación actual
      child: CircleAvatar(
        backgroundColor: Colors.white,
        maxRadius: 25,
        // BlocBuilder para saber si se sigue al usuario.
        child: IconButton(
            icon: Icon(Icons.quiz_rounded, color: Colors.black),
            onPressed: () async {
              // start: posición del usuario o primer punto de la ruta:
             // final start = locationBloc.state.lastKnownLocation;
              // si no hay ubicación cancela.
              //if (start == null) return;
              // end: valor central del mapa desde el mapbloc
              //final end = mapBloc.mapCenter;
              //if (end == null) return;

              //Mensaje de carga:
              //LoadingMessageHelper.showLoadingMessage(context);

              // Calcula la polilínea a mostrar por el mapbloc
              final destination = await searchBloc.getOptimizedRoute(salamancaCoordinates);

              // Se llama a pintar nueva polilínea:
              await mapBloc.drawRoutePolyline(destination);
            }),
      ),
    );
  }
}
