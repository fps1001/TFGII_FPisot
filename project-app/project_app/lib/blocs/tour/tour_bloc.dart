import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/exceptions/exceptions.dart';
import 'package:project_app/persistence_bd/repositories/repositories.dart';
import 'package:project_app/services/services.dart';

part 'tour_event.dart';
part 'tour_state.dart';

/// Bloc encargado de gestionar el estado de los tours turísticos.
///
/// Este Bloc se ocupa de:
/// - Crear, modificar y mostrar tours.
/// - Obtener puntos de interés (POIs) desde Gemini y Google Places.
/// - Optimizar rutas mediante un servicio externo.
/// - Guardar y cargar tours en el repositorio.
///
/// Este Bloc depende de [MapBloc] para dibujar rutas y marcadores en el mapa.
class TourBloc extends Bloc<TourEvent, TourState> {
  /// Servicio utilizado para optimizar rutas entre puntos de interés (POIs).
  final OptimizationService optimizationService;

  /// Bloc encargado de gestionar el mapa y los marcadores.
  final MapBloc mapBloc;

  /// Repositorio utilizado para guardar y cargar tours en persistencia.
  final EcoCityTourRepository ecoCityTourRepository;

  /// Constructor de [TourBloc].
  ///
  /// Requiere instancias de [OptimizationService], [MapBloc] y [EcoCityTourRepository].
  TourBloc({
    required this.mapBloc,
    required this.optimizationService,
    required this.ecoCityTourRepository,
  }) : super(const TourState()) {
    // Manejar los eventos que se pueden emitir al TourBloc
    on<LoadTourEvent>(_onLoadTour); // Cargar un nuevo tour
    on<OnRemovePoiEvent>(_onRemovePoi); // Eliminar un POI del tour
    on<OnAddPoiEvent>(_onAddPoi); // Añadir un POI al tour
    on<OnJoinTourEvent>(_onJoinTour); // Unirse al tour
    on<ResetTourEvent>((event, emit) {
      // Resetear el tour actual
      emit(state.copyWith(ecoCityTour: null, isJoined: false));
      mapBloc.add(const OnClearMapEvent()); // Limpia el mapa
    });
    on<LoadSavedToursEvent>(_onLoadSavedTours); // Cargar tours guardados
    on<LoadTourFromSavedEvent>(_onLoadTourFromSaved); // Cargar un tour guardado
  }

  /// Lógica para cargar un nuevo tour basado en las preferencias del usuario.
  ///
  /// Pasos:
  /// 1. Obtiene POIs desde el servicio Gemini.
  /// 2. Recupera información adicional de Google Places.
  /// 3. Optimiza la ruta entre los POIs.
  /// 4. Actualiza el estado del Bloc con el nuevo tour.
  /// 5. Manda a pintar la ruta en el [MapBloc].
  Future<void> _onLoadTour(LoadTourEvent event, Emitter<TourState> emit) async {
    log.i(
        'TourBloc: Loading tour for city: ${event.city}, with ${event.numberOfSites} sites');
    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      // Obtener POIs desde el servicio Gemini
      final pois = await GeminiService.fetchGeminiData(
        city: event.city,
        nPoi: event.numberOfSites,
        userPreferences: event.userPreferences,
        maxTime: event.maxTime,
        mode: event.mode,
        systemInstruction: event.systemInstruction,
      );
      log.d('TourBloc: Fetched ${pois.length} POIs for ${event.city}');

      // Obtener información adicional de Google Places
      List<PointOfInterest> updatedPois = [];
      for (PointOfInterest poi in pois) {
        final placeData =
            await PlacesService().searchPlace(poi.name, event.city);

        if (placeData != null) {
          // Actualizar POI con datos de Google Places
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
            imageUrl: placeData['photos'] != null &&
                    placeData['photos'].isNotEmpty
                ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${placeData['photos'][0]['photo_reference']}&key=$apiKey'
                : poi.imageUrl,
            rating: placeData['rating']?.toDouble() ?? poi.rating,
            address: placeData['formatted_address'],
            userRatingsTotal: placeData['user_ratings_total'],
          );
          updatedPois.add(updatedPoi);
        } else {
          updatedPois.add(poi); // Si no hay información extra, usar el original
        }
      }

      // Optimizar la ruta con los POIs actualizados
      final ecoCityTour = await optimizationService.getOptimizedRoute(
        pois: updatedPois,
        mode: event.mode,
        city: event.city,
        userPreferences: event.userPreferences,
      );

      // Emitir el estado con el tour cargado
      emit(state.copyWith(ecoCityTour: ecoCityTour, isLoading: false));
      log.i('TourBloc: Successfully loaded tour for ${event.city}');

      // Mandar a pintar la ruta en el MapBloc
      await mapBloc.drawEcoCityTour(ecoCityTour);
    } catch (e) {
      if (e is AppException || e is DioException) {
        log.e('TourBloc: Error loading tour: $e', error: e);
      }
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  /// Evento para unirse al tour.
  ///
  /// Cambia el estado `isJoined` al valor contrario.
  Future<void> _onJoinTour(
      OnJoinTourEvent event, Emitter<TourState> emit) async {
    log.i('TourBloc: User joined the tour');
    emit(state.copyWith(isJoined: !state.isJoined));
  }

  /// Añade un nuevo POI al tour actual.
  ///
  /// Si el tour actual no existe, no realiza ninguna acción.
  Future<void> _onAddPoi(OnAddPoiEvent event, Emitter<TourState> emit) async {
    log.i('TourBloc: Añadiendo POI: ${event.poi.name}');

    final ecoCityTour = state.ecoCityTour;
    if (ecoCityTour == null) return;

    emit(state.copyWith(isLoading: true));

    try {
      // Añadir el nuevo POI a la lista de POIs
      final updatedPois = List<PointOfInterest>.from(ecoCityTour.pois)
        ..add(event.poi);

      // Optimizar el tour con los nuevos POIs
      await _updateTourWithPois(updatedPois, emit);

      // Añadir el marcador al mapa
      mapBloc.add(OnAddPoiMarkerEvent(event.poi));
    } catch (e) {
      log.e('Error añadiendo el POI: $e');
      emit(state.copyWith(hasError: true));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Elimina un POI del tour actual.
  ///
  /// También elimina el marcador correspondiente del mapa.
  Future<void> _onRemovePoi(
      OnRemovePoiEvent event, Emitter<TourState> emit) async {
    log.i('TourBloc: Eliminando POI: ${event.poi.name}');

    final ecoCityTour = state.ecoCityTour;
    if (ecoCityTour == null) return;

    emit(state.copyWith(isLoading: true));

    try {
      // Eliminar el POI de la lista
      final updatedPois = List<PointOfInterest>.from(ecoCityTour.pois)
        ..remove(event.poi);

      // Si se elimina la ubicación actual, cambiar isJoined a false
      if (event.poi.name == 'current_location'.tr()) {
        log.i(
            'El POI eliminado es la ubicación actual. Cambiando isJoined a false.');
        emit(state.copyWith(isJoined: false));
      }

      // Optimizar el tour con los POIs restantes
      await _updateTourWithPois(updatedPois, emit);

      // Eliminar el marcador del mapa
      mapBloc.add(OnRemovePoiMarkerEvent(event.poi.name));
    } catch (e) {
      log.e('Error eliminando el POI: $e');
      emit(state.copyWith(hasError: true));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Optimiza un tour basado en una lista actualizada de POIs.
  Future<void> _updateTourWithPois(
      List<PointOfInterest> pois, Emitter<TourState> emit) async {
    log.d('TourBloc: Updating tour with ${pois.length} POIs');

    if (pois.isEmpty) {
      emit(state.copyWithNull());
      return;
    }

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

      // Dibujar el tour optimizado en el mapa
      await mapBloc.drawEcoCityTour(ecoCityTour);
    } catch (e) {
      emit(state.copyWith(hasError: true));
    }
  }

  /// Guarda el tour actual en el repositorio.
  Future<void> saveCurrentTour(String tourName) async {
    if (state.ecoCityTour == null) return;
    await ecoCityTourRepository.saveTour(state.ecoCityTour!, tourName);
  }

  /// Carga todos los tours guardados desde el repositorio.
  Future<void> _onLoadSavedTours(
      LoadSavedToursEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final savedTours = await ecoCityTourRepository.getSavedTours();
      emit(state.copyWith(isLoading: false, savedTours: savedTours));
      log.i('Tours guardados cargados exitosamente');
    } catch (e) {
      log.e('Error al cargar los tours guardados: $e');
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  /// Carga un tour guardado específico desde el repositorio.
  Future<void> _onLoadTourFromSaved(
      LoadTourFromSavedEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      final savedTour =
          await ecoCityTourRepository.getTourById(event.documentId);

      if (savedTour != null) {
        emit(state.copyWith(ecoCityTour: savedTour, isLoading: false));
        log.i('Tour cargado correctamente desde Firestore: ${savedTour.city}');

        // Pintar la ruta en el mapa
        await mapBloc.drawEcoCityTour(savedTour);
      } else {
        log.w('El tour no existe o es nulo.');
        emit(state.copyWith(isLoading: false, hasError: true));
      }
    } catch (e) {
      log.e('Error al cargar el tour desde Firestore: $e');
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }
}
