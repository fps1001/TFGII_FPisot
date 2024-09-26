import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/exceptions/exceptions.dart';
import 'package:project_app/services/services.dart';

part 'tour_event.dart';
part 'tour_state.dart';

class TourBloc extends Bloc<TourEvent, TourState> {
  final OptimizationService optimizationService;

  TourBloc({required this.optimizationService}) : super(const TourState()) {
    on<LoadTourEvent>(_onLoadTour);
  }

  Future<void> _onLoadTour(LoadTourEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      // 1. Obtener puntos de interés (POIs) desde el servicio Gemini.
      final pois = await GeminiService.fetchGeminiData(
        city: event.city,
        nPoi: event.numberOfSites,
        userPreferences: event.userPreferences,
      );

      // 2. Llamar al servicio de Places para mejorar los datos de cada POI
      List<PointOfInterest> updatedPois = [];

      for (PointOfInterest poi in pois) {
        final placeData =
            await PlacesService().searchPlace(poi.name, event.city);

        // Si el servicio de Places devuelve datos, actualizamos el POI con la nueva información
        if (placeData != null) {
          final String apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
          final location = placeData['location'];
          final updatedPoi = PointOfInterest(
            gps: location != null
                ? LatLng(
                    location['lat']?.toDouble() ?? poi.gps.latitude,
                    location['lng']?.toDouble() ?? poi.gps.longitude,
                  )
                : poi.gps,

            name: placeData['name'] ?? poi.name,
            description: placeData['editorialSummary'] ?? poi.description,
            url: placeData['website'] ?? poi.url,

            // Verificar si hay fotos y construir la URL si es posible
            imageUrl: placeData['photos'] != null &&
                    placeData['photos'].isNotEmpty
                ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${placeData['photos'][0]['photo_reference']}&key=$apiKey'
                : poi.imageUrl,

            rating: placeData['rating']?.toDouble() ?? poi.rating,

            // Información adicional del lugar
            address: placeData['formatted_address'],
            iconUrl: placeData['icon'],
            businessStatus: placeData['business_status'],
            placeId: placeData['place_id'],
            plusCode: placeData['plus_code'],
              openNow: (placeData['opening_hours'] is Map)
                  ? placeData['opening_hours']['open_now'] ?? false
                  : placeData['opening_hours'] ?? false, // Verificamos si es Map o bool
            userRatingsTotal: placeData['user_ratings_total'],
          );
          updatedPois.add(updatedPoi);
        } else {
          // Si no se encuentra información adicional, agregamos el POI original
          updatedPois.add(poi);
        }
      }

      // 3. Llamar al servicio de optimización de rutas.
      final List<LatLng> poiLocations = updatedPois.map((poi) => poi.gps).toList();
      final optimizedRoute = await optimizationService.getOptimizedRoute(
        poiLocations,
        event.mode,
      );

      // 4. Crear la instancia de EcoCityTour con los datos obtenidos.
      final ecoCityTour = EcoCityTour(
        city: event.city,
        numberOfSites: updatedPois.length,
        pois: updatedPois,
        mode: event.mode,
        userPreferences: event.userPreferences,
        duration: optimizedRoute.duration,
        distance: optimizedRoute.distance,
        polilynePoints: optimizedRoute.points,
      );

      // 5. Emitir el estado con el tour cargado.
      emit(state.copyWith(ecoCityTour: ecoCityTour, isLoading: false));
    } catch (e) {
      if (e is AppException || e is DioException) {
        if (kDebugMode) {
          print(e.toString());
        }
      }
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }
}
