import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/exceptions/exceptions.dart';
import 'package:project_app/services/services.dart';

part 'tour_event.dart';
part 'tour_state.dart';

class TourBloc extends Bloc<TourEvent, TourState> {
  final OptimizationService optimizationService;
  final MapBloc mapBloc; // Añadimos una referencia al MapBloc para marcadores

  TourBloc({required this.mapBloc, required this.optimizationService})
      : super(const TourState()) {
    // Manejadores de eventos a continuación
    on<LoadTourEvent>(_onLoadTour);
    on<OnRemovePoiEvent>(_onRemovePoi);
    on<OnAddPoiEvent>(_onAddPoi);
    on<OnJoinTourEvent>(_onJoinTour);
    // Reset de Tour. Emite estado con EcoCityTour y POI's a null.
    on<ResetTourEvent>((event, emit) {
      emit(state.copyWith(ecoCityTour: null, isJoined: false));
      // Limpia el mapa al resetear el tour
      mapBloc.add(OnClearMapEvent());
    });
  }

  Future<void> _onLoadTour(LoadTourEvent event, Emitter<TourState> emit) async {
    log.i(
        'TourBloc: Loading tour for city: ${event.city}, with ${event.numberOfSites} sites');
    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      // 1. Obtener puntos de interés (POIs) desde el servicio Gemini.
      final pois = await GeminiService.fetchGeminiData(
          city: event.city,
          nPoi: event.numberOfSites,
          userPreferences: event.userPreferences,
          maxTime: event.maxTime,
          mode: event.mode);
      log.d('TourBloc: Fetched ${pois.length} POIs for ${event.city}');
      // 2. **Recuperar información adicional de Google Places**
      List<PointOfInterest> updatedPois = [];
      for (PointOfInterest poi in pois) {
        final placeData =
            await PlacesService().searchPlace(poi.name, event.city);

        if (placeData != null) {
          log.d('TourBloc: Updating POI with Google Places data: ${poi.name}');
          final String apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
          final location = placeData['location'];

          // Actualizar POI con información de Google Places
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
            imageUrl: placeData['photos'] != null &&
                    placeData['photos'].isNotEmpty
                ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${placeData['photos'][0]['photo_reference']}&key=$apiKey'
                : poi.imageUrl,
            rating: placeData['rating']?.toDouble() ?? poi.rating,
            address: placeData['formatted_address'],
            userRatingsTotal: placeData['user_ratings_total'],
          );
          updatedPois.add(updatedPoi); // Añadimos el POI actualizado
        } else {
          updatedPois
              .add(poi); // Si no hay información extra, añadimos el original
        }
      }

      // 3. Llamar al servicio de optimización de rutas con los POIs actualizados
      final ecoCityTour = await optimizationService.getOptimizedRoute(
        pois: updatedPois, // Usa la lista de POIs actualizada
        mode: event.mode,
        city: event.city,
        userPreferences: event.userPreferences, 
      );

      // 4. Emitir el estado con el tour cargado.
      emit(state.copyWith(ecoCityTour: ecoCityTour, isLoading: false));
      log.i('TourBloc: Successfully loaded tour for ${event.city}');
    } catch (e) {
      if (e is AppException || e is DioException) {
        log.e('TourBloc: Error loading tour: $e', error: e);
      }
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  // Manejo del evento de unirse al tour
  Future<void> _onJoinTour(
      OnJoinTourEvent event, Emitter<TourState> emit) async {
    log.i('TourBloc: User joined the tour');
    // Cambiar el valor de isJoined al valor contrario
    emit(state.copyWith(isJoined: !state.isJoined));
  }

  // Método para añadir un POI
  Future<void> _onAddPoi(OnAddPoiEvent event, Emitter<TourState> emit) async {
    log.i('TourBloc: Adding POI: ${event.poi.name}');
    final ecoCityTour = state.ecoCityTour;
    if (ecoCityTour == null) return;

    emit(state.copyWith(isLoading: true));
    final updatedPois = List<PointOfInterest>.from(ecoCityTour.pois)
      ..add(event.poi);

    await _updateTourWithPois(updatedPois, emit);

    // Añadir el marcador en el mapa usando MapBloc
    mapBloc.add(OnAddPoiMarkerEvent(event.poi));
    emit(state.copyWith(isLoading: false));
  }

  // Método para eliminar un POI (comprobando que sea o no la ubicación actual)
  Future<void> _onRemovePoi(
      OnRemovePoiEvent event, Emitter<TourState> emit) async {
    log.i('TourBloc: Removing POI: ${event.poi.name}');
    final ecoCityTour = state.ecoCityTour;
    if (ecoCityTour == null) return;

    // Establece isLoading a true antes de recalcular la ruta
    emit(state.copyWith(isLoading: true));

    // Remover el POI de la lista
    final updatedPois = List<PointOfInterest>.from(ecoCityTour.pois)
      ..remove(event.poi);

    // Comprobar si el POI eliminado es la ubicación del usuario
    if (event.poi.name == 'Ubicación actual' ||
        event.poi.description == 'Este es mi lugar actual') {
      // Actualizar el estado de `isJoined` a false si se eliminó el POI del usuario
      emit(state.copyWith(isJoined: false));
    }

    // Llamamos a _updateTourWithPois para recalcular la ruta si hay POIs
    await _updateTourWithPois(updatedPois, emit);

    // Usar el MapBloc para eliminar el marcador
    mapBloc.add(OnRemovePoiMarkerEvent(event.poi.name));
    // Fin de carga.
    emit(state.copyWith(isLoading: false));
  }

  // Método para optimizar el tour que ha sufrido algún cambio de POIs y
  // llamar a pintarlo -> MapBloc
  Future<void> _updateTourWithPois(
    List<PointOfInterest> pois,
    Emitter<TourState> emit,
  ) async {
    log.d('TourBloc: Updating tour with ${pois.length} POIs');
    if (pois.isNotEmpty) {
      try {
        // Recalcular la ruta optimizada
        final ecoCityTour = await optimizationService.getOptimizedRoute(
          pois: pois,
          mode: state.ecoCityTour!.mode,
          city: state.ecoCityTour!.city,
          userPreferences: state.ecoCityTour!.userPreferences,
        );

        // Emitir el nuevo estado del tour
        emit(state.copyWith(ecoCityTour: ecoCityTour));

        // Llamar al método drawRoutePolyline del MapBloc para actualizar el mapa
        await mapBloc.drawEcoCityTour(ecoCityTour);
      } catch (e) {
        emit(state.copyWith(hasError: true));
      }
    } else {
      // Si no quedan POIs, emitimos el estado sin una ruta actual
      
      emit(state.copyWithNull());
    }
  }
}
