import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger

import 'package:project_app/models/models.dart';
import 'package:project_app/services/services.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/ui/ui.dart'; // Para usar el CustomSnackbar

class SearchDestinationDelegate extends SearchDelegate<PointOfInterest?> {
  final PlacesService _placesService = PlacesService(); // Servicio de Google Places
  final String apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  SearchDestinationDelegate() : super(searchFieldLabel: 'Buscar un lugar...');
  
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          log.d('SearchDestinationDelegate: Buscador limpiado');
          query = ''; // Limpiar búsqueda
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        log.d('SearchDestinationDelegate: Volviendo atrás desde el buscador');
        close(context, null); // Cerrar el buscador
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Obtener la ciudad actual desde el TourBloc
    final tourState = BlocProvider.of<TourBloc>(context).state;

    // Comprobar si el estado tiene un EcoCityTour asignado
    if (tourState.ecoCityTour == null || tourState.ecoCityTour!.city.isEmpty) {
      log.w('SearchDestinationDelegate: No se ha seleccionado ninguna ciudad');
      return const Center(child: Text('No se ha seleccionado ninguna ciudad.'));
    }

    final String city = tourState.ecoCityTour!.city;

    log.i('SearchDestinationDelegate: Realizando búsqueda en Google Places para: "$query" en la ciudad: "$city"');

    // Retornar un FutureBuilder para esperar los resultados de la búsqueda
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: _placesService.searchPlaces(query, city), // Cambié el método para buscar una lista de lugares
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          // Mostrar snackbar antes de cerrar el buscador
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ScaffoldMessenger.of(context).mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackbar(msg: 'No se encontró ningún lugar.'),
              );
            }
            close(context, null); // Cerrar el buscador y volver al mapa
          });
          return const SizedBox();
        }

        // Mostrar los resultados como una lista de opciones para que el usuario elija
        final places = snapshot.data!;
        return ListView.builder(
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return ListTile(
              title: Text(place['name']),
              subtitle: Text(place['formatted_address']),
              onTap: () {
                // Crear el POI con la selección del usuario
                final pointOfInterest = PointOfInterest(
                  gps: LatLng(place['location']['lat'], place['location']['lng']),
                  name: place['name'],
                  description: place['formatted_address'],
                  url: place['website'],
                  imageUrl: place['photos'] != null && place['photos'].isNotEmpty
                      ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place['photos'][0]['photo_reference']}&key=$apiKey'
                      : null,
                  rating: place['rating']?.toDouble(),
                  address: place['formatted_address'],
                  userRatingsTotal: place['user_ratings_total'],
                );

                log.i('SearchDestinationDelegate: POI seleccionado: ${pointOfInterest.name}, ${pointOfInterest.address}');

                // Agregar el POI al estado del TourBloc y al MapBloc
                BlocProvider.of<TourBloc>(context).add(OnAddPoiEvent(poi: pointOfInterest));
                BlocProvider.of<MapBloc>(context).add(OnAddPoiMarkerEvent(pointOfInterest));

                // Cerrar el buscador tras seleccionar el POI
                close(context, pointOfInterest);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    log.d('SearchDestinationDelegate: Mostrando sugerencias de búsqueda.');
    return const Center(child: Text('Escribe el nombre de un lugar que quieras añadir.'));
  }
}
