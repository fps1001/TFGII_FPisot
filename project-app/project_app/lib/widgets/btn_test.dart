import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/services.dart';

import '../blocs/blocs.dart';

class BtnTest extends StatelessWidget {
  BtnTest({super.key});

  final List<String> userPreferences = ['Historia', 'Deportes'];

  @override
  Widget build(BuildContext context) {
    final searchBloc =
        BlocProvider.of<SearchBloc>(context); // Para obtener la ruta optimizada
    final mapBloc =
        BlocProvider.of<MapBloc>(context); // Para dibujar la polilínea
    final locationBloc = BlocProvider.of<LocationBloc>(
        context); // Para obtener la última ubicación conocida

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      // Botón de centrado en la ubicación actual
      child: CircleAvatar(
        backgroundColor: Colors.white,
        maxRadius: 25,
        // BlocBuilder para saber si se sigue al usuario.
        child: IconButton(
          icon: const Icon(Icons.quiz_rounded, color: Colors.black),
          onPressed: () async {
            // Obtener la última ubicación conocida
            final lastKnownLocation = locationBloc.state.lastKnownLocation;

            // Obtener POIs desde el servicio Gemini
            final List<PointOfInterest> pois =
                await GeminiService.fetchGeminiData(
                    city: 'Salamanca',
                    nPoi: 4,
                    userPreferences: userPreferences);

            // Si no se obtienen POIs, cancelar la acción
            if (pois.isEmpty) {
              print('No points of interest found.');
              return;
            }

            // Añadir la ubicación del usuario como el primer POI, si existe
            final List<PointOfInterest> allPOIs = lastKnownLocation != null
                ? [
                    PointOfInterest(
                      gps: lastKnownLocation,
                      name: 'Tu ubicación actual',
                      description: 'Última ubicación conocida del usuario',
                    ),
                    ...pois
                  ]
                : pois;

            // Convertir la lista de PointOfInterest a una lista de LatLng
            final List<LatLng> salamancaCoordinates =
                allPOIs.map((poi) => poi.gps).toList();

            // Si no hay coordenadas (aunque improbable porque ya hay validación previa), cancelar la acción
            if (salamancaCoordinates.isEmpty) {
              if (kDebugMode) {
                print('No coordinates found.');
              }
              return;
            }

            // Obtener la ruta optimizada
            final destination = await searchBloc.getOptimizedRoute(
                salamancaCoordinates, 'walking');

            // Pintar la nueva polilínea en el mapa
            await mapBloc.drawRoutePolyline(destination, allPOIs);
          },
        ),
      ),
    );
  }
}
