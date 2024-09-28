import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/exceptions/exceptions.dart';
import 'package:project_app/services/services.dart';

part 'tour_event.dart';
part 'tour_state.dart';

class TourBloc extends Bloc<TourEvent, TourState> {
  final OptimizationService optimizationService;
  final MapBloc mapBloc; // Añadimos una referencia al MapBloc para marcadores

  TourBloc({required this.mapBloc, required this.optimizationService}) : super(const TourState()) {
    // Manejadores de eventos a continuación
    on<LoadTourEvent>(_onLoadTour);
    on<OnRemovePoiEvent>(_onRemovePoi);
    on<OnAddPoiEvent>(_onAddPoi);
    on<OnJoinTourEvent>(_onJoinTour);
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
            //iconUrl: placeData['icon'],
            iconUrl: null,
            businessStatus: placeData['business_status'],
            //placeId: placeData['place_id'],
            placeId: null,
            //plusCode: placeData['plus_code'],
            plusCode: null,
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

 // Manejo del evento de unirse al tour
  Future<void> _onJoinTour(OnJoinTourEvent event, Emitter<TourState> emit) async {
    if (!state.isJoined) {
      emit(state.copyWith(isJoined: true));
    }
  }

  // Método para añadir un POI
  Future<void> _onAddPoi(OnAddPoiEvent event, Emitter<TourState> emit) async {
    if (state.ecoCityTour != null) {
      final updatedPois = List<PointOfInterest>.from(state.ecoCityTour!.pois)
        ..add(event.poi);

      // Actualizamos el tour con los nuevos POIs
      await _updateTourWithPois(updatedPois, emit);

      // Añadir el marcador en el mapa usando MapBloc
      mapBloc.add(OnAddPoiMarkerEvent(event.poi));
    }
  }

  // Método para eliminar un POI (comprobando que sea o no la ubicación actual)
 Future<void> _onRemovePoi(OnRemovePoiEvent event, Emitter<TourState> emit) async {
  final ecoCityTour = state.ecoCityTour;
  if (ecoCityTour == null) return;

  // Remover el POI de la lista
  final updatedPois = List<PointOfInterest>.from(ecoCityTour.pois)..remove(event.poi);

  // Comprobar si el POI eliminado es la ubicación del usuario
  if (event.poi.name == 'Ubicación actual' || event.poi.description == 'Este es mi lugar actual') {
    // Actualizar el estado de `isJoined` a false si se eliminó el POI del usuario
    emit(state.copyWith(isJoined: false));
  }

  // Recalcular la ruta optimizada si aún quedan POIs
  if (updatedPois.isNotEmpty) {
    final List<LatLng> poiLocations = updatedPois.map((poi) => poi.gps).toList();
    final optimizedRoute = await optimizationService.getOptimizedRoute(
      poiLocations,
      ecoCityTour.mode,
    );

    // Crear una nueva instancia de EcoCityTour con los datos actualizados
    final updatedEcoCityTour = EcoCityTour(
      city: ecoCityTour.city,
      numberOfSites: updatedPois.length,
      pois: updatedPois,
      mode: ecoCityTour.mode,
      userPreferences: ecoCityTour.userPreferences,
      duration: optimizedRoute.duration,
      distance: optimizedRoute.distance,
      polilynePoints: optimizedRoute.points,
    );

    // Emitir el nuevo estado con el tour actualizado
    emit(state.copyWith(ecoCityTour: updatedEcoCityTour));
  } else {
    // Si no quedan POIs, emitimos el estado sin una ruta actual
    emit(state.copyWith(ecoCityTour: null));
  }

  // Usar el MapBloc para eliminar el marcador
  mapBloc.add(OnRemovePoiMarkerEvent(event.poi.name));
}




  // Método para actualizar el tour con una nueva lista de POIs
  Future<void> _updateTourWithPois(
    List<PointOfInterest> pois,
    Emitter<TourState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final List<LatLng> poiLocations = pois.map((poi) => poi.gps).toList();
      final optimizedRoute = await optimizationService.getOptimizedRoute(
        poiLocations,
        state.ecoCityTour!.mode,
      );

      final updatedTour = state.ecoCityTour!.copyWith(
        pois: pois,
        numberOfSites: pois.length,
        duration: optimizedRoute.duration,
        distance: optimizedRoute.distance,
        polilynePoints: optimizedRoute.points,
      );

      emit(state.copyWith(ecoCityTour: updatedTour, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }


}
