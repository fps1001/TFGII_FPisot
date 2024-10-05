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

    log.i(
        'SearchDestinationDelegate: Realizando búsqueda en Google Places para: "$query" en la ciudad: "$city"');

    // Retornar un FutureBuilder para esperar los resultados de la búsqueda
    return FutureBuilder<Map<String, dynamic>?>(
      future: _placesService.searchPlace(query, city),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          // Mostrar snackbar antes de cerrar el buscador
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ScaffoldMessenger.of(context).mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackbar(msg: 'No se encontró dicho lugar.'),
              );
            }
            close(context, null); // Cerrar el buscador y volver al mapa
          });
          return const SizedBox();
        }

        // Crear un PointOfInterest con la respuesta de Google Places
        final placeData = snapshot.data!;
        final pointOfInterest = PointOfInterest(
          gps: LatLng(
              placeData['location']['lat'], placeData['location']['lng']),
          name: placeData['name'],
          description: placeData['formatted_address'],
          url: placeData['website'],
          imageUrl: placeData['photos'] != null &&
                  placeData['photos'].isNotEmpty
              ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${placeData['photos'][0]['photo_reference']}&key=$apiKey'
              : null,
          rating: placeData['rating']?.toDouble(),
          address: placeData['formatted_address'],
          userRatingsTotal: placeData['user_ratings_total'],
        );

        log.i(
            'SearchDestinationDelegate: POI encontrado y creado: ${pointOfInterest.name}, ${pointOfInterest.address}');

        // Agregar el POI al estado del TourBloc y al MapBloc inmediatamente
        BlocProvider.of<TourBloc>(context)
            .add(OnAddPoiEvent(poi: pointOfInterest));
        BlocProvider.of<MapBloc>(context)
            .add(OnAddPoiMarkerEvent(pointOfInterest));

        // Cerrar el buscador tras seleccionar el POI
        WidgetsBinding.instance.addPostFrameCallback((_) {
          close(context, pointOfInterest);
        });

        return const SizedBox();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    log.d('SearchDestinationDelegate: Mostrando sugerencias de búsqueda.');
    return const Center(child: Text('Escribe el nombre de un lugar...'));
  }
}
