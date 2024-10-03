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
  final PlacesService _placesService =
      PlacesService(); // Servicio de Google Places
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

    // Log para la búsqueda que se va a realizar
    log.i(
        'SearchDestinationDelegate: Realizando búsqueda en Google Places para: "$query" en la ciudad: "$city"');

    // Realizar la búsqueda con la ciudad actual
    return FutureBuilder<Map<String, dynamic>?>(
      future: _placesService.searchPlace(
          query, city), // Pasar la ciudad obtenida del TourBloc
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          log.d(
              'SearchDestinationDelegate: Esperando respuesta de Google Places');
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          log.w('SearchDestinationDelegate: No se encontró el lugar: "$query"');
          // Mostrar un mensaje usando CustomSnackbar
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar(msg: 'No se encontró dicho lugar.'),
          );

          // Usar Future.delayed para cerrar el buscador después de que se complete el ciclo de construcción
          Future.delayed(Duration.zero, () {
            log.d(
                'SearchDestinationDelegate: Cerrando el buscador después de no encontrar lugar.');
            close(context, null); // Cerrar el buscador y volver al mapa
          });

          return const SizedBox();
        }

        final placeData = snapshot.data;

        // Crear un PointOfInterest con la respuesta de Google Places
        final pointOfInterest = PointOfInterest(
          gps: LatLng(
              placeData!['location']['lat'], placeData['location']['lng']),
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

        // Disparar el evento para añadir el POI al tour usando el TourBloc
        BlocProvider.of<TourBloc>(context)
            .add(OnAddPoiEvent(poi: pointOfInterest));

        // Disparar el evento para añadir el marcador en el mapa usando el MapBloc
        BlocProvider.of<MapBloc>(context)
            .add(OnAddPoiMarkerEvent(pointOfInterest));

        // Usar Future.delayed para cerrar el buscador después de que se complete el ciclo de construcción
        Future.delayed(Duration.zero, () {
          log.d(
              'SearchDestinationDelegate: Cerrando el buscador tras seleccionar un POI.');
          close(context,
              pointOfInterest); // Cerrar el buscador al seleccionar el resultado
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
