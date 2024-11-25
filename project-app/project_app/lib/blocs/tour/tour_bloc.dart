import 'dart:async';
import 'package:bloc/bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart';
import 'package:project_app/models/models.dart';

import 'package:project_app/repositories/repositories.dart';
import 'package:project_app/services/services.dart';

part 'tour_event.dart';
part 'tour_state.dart';

class TourBloc extends Bloc<TourEvent, TourState> {
  final OptimizationService optimizationService;
  final MapBloc mapBloc;
  final EcoCityTourRepository ecoCityTourRepository;

  TourBloc({
    required this.mapBloc,
    required this.optimizationService,
    required this.ecoCityTourRepository,
  }) : super(const TourState()) {
    _initializeEventHandlers();
  }

  void _initializeEventHandlers() {
    on<LoadTourEvent>(_handleLoadTour);
    on<OnAddPoiEvent>(_handleAddPoi);
    on<OnRemovePoiEvent>(_handleRemovePoi);
    on<OnJoinTourEvent>(_toggleJoinTour);
    on<ResetTourEvent>(_resetTour);
    on<LoadSavedToursEvent>(_handleLoadSavedTours);
    on<LoadTourFromSavedEvent>(_handleLoadTourFromSaved);
  }

  Future<void> _handleLoadTour(LoadTourEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      final pois = await _fetchPOIs(event);
      final updatedPois = await _fetchAdditionalPoiData(pois, event.city);
      final ecoCityTour = await _optimizeRoute(updatedPois, event);

      emit(state.copyWith(ecoCityTour: ecoCityTour, isLoading: false));
      await mapBloc.drawEcoCityTour(ecoCityTour);

    } catch (error) {
      _handleError(error, emit);
    }
  }

  Future<List<PointOfInterest>> _fetchPOIs(LoadTourEvent event) {
    return GeminiService.fetchGeminiData(
      city: event.city,
      nPoi: event.numberOfSites,
      userPreferences: event.userPreferences,
      maxTime: event.maxTime,
      mode: event.mode,
      systemInstruction: event.systemInstruction,
    );
  }

  Future<List<PointOfInterest>> _fetchAdditionalPoiData(List<PointOfInterest> pois, String city) async {
    List<PointOfInterest> updatedPois = [];
    for (var poi in pois) {
      final placeData = await PlacesService().searchPlace(poi.name, city);
      updatedPois.add(_updatePoiWithPlaceData(poi, placeData));
    }
    return updatedPois;
  }

  PointOfInterest _updatePoiWithPlaceData(PointOfInterest poi, Map<String, dynamic>? placeData) {
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    if (placeData == null) return poi;

    return PointOfInterest(
      gps: placeData['location'] != null
          ? LatLng(placeData['location']['lat'], placeData['location']['lng'])
          : poi.gps,
      name: placeData['name'] ?? poi.name,
      description: placeData['editorialSummary'] ?? poi.description,
      url: placeData['website'] ?? poi.url,
      imageUrl: placeData['photos']?.isNotEmpty == true
          ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${placeData['photos'][0]['photo_reference']}&key=$apiKey'
          : poi.imageUrl,
      rating: placeData['rating']?.toDouble() ?? poi.rating,
      address: placeData['formatted_address'] ?? poi.address,
      userRatingsTotal: placeData['user_ratings_total'],
    );
  }

  Future<EcoCityTour> _optimizeRoute(List<PointOfInterest> pois, LoadTourEvent event) {
    return optimizationService.getOptimizedRoute(
      pois: pois,
      mode: event.mode,
      city: event.city,
      userPreferences: event.userPreferences,
    );
  }

  Future<void> _handleAddPoi(OnAddPoiEvent event, Emitter<TourState> emit) async {
    final ecoCityTour = state.ecoCityTour;
    if (ecoCityTour == null) return;

    emit(state.copyWith(isLoading: true));
    try {
      final updatedPois = List<PointOfInterest>.from(ecoCityTour.pois)..add(event.poi);
      await _updateTourWithPois(updatedPois, emit);
      mapBloc.add(OnAddPoiMarkerEvent(event.poi));
    } catch (error) {
      _handleError(error, emit);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _handleRemovePoi(OnRemovePoiEvent event, Emitter<TourState> emit) async {
    final ecoCityTour = state.ecoCityTour;
    if (ecoCityTour == null) return;

    emit(state.copyWith(isLoading: true));
    try {
      final updatedPois = List<PointOfInterest>.from(ecoCityTour.pois)..remove(event.poi);
      await _updateTourWithPois(updatedPois, emit);
      if (event.shouldUpdateMap) {
        mapBloc.add(OnRemovePoiMarkerEvent(event.poi.name));
      }
    } catch (error) {
      _handleError(error, emit);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _updateTourWithPois(List<PointOfInterest> pois, Emitter<TourState> emit) async {
    if (pois.isEmpty) {
      emit(state.copyWithNull());
      return;
    }

    try {
      final ecoCityTour = await optimizationService.getOptimizedRoute(
        pois: pois,
        mode: state.ecoCityTour!.mode,
        city: state.ecoCityTour!.city,
        userPreferences: state.ecoCityTour!.userPreferences,
      );
      emit(state.copyWith(ecoCityTour: ecoCityTour));
      await mapBloc.drawEcoCityTour(ecoCityTour);
    } catch (error) {
      _handleError(error, emit);
    }
  }

  Future<void> _toggleJoinTour(OnJoinTourEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(isJoined: !state.isJoined));
  }

  Future<void> _resetTour(ResetTourEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(ecoCityTour: null, isJoined: false));
    mapBloc.add(OnClearMapEvent());
  }

  Future<void> _handleLoadSavedTours(LoadSavedToursEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final savedTours = await ecoCityTourRepository.getSavedTours();
      emit(state.copyWith(savedTours: savedTours, isLoading: false));
    } catch (error) {
      _handleError(error, emit);
    }
  }

  // Método para guardar el tour actual en el repositorio
Future<void> saveCurrentTour(String tourName) async {
  if (state.ecoCityTour == null) {
    log.w('No se puede guardar un tour vacío.');
    return;
  }
  try {
    await ecoCityTourRepository.saveTour(state.ecoCityTour!, tourName);
    log.i('Tour guardado exitosamente con nombre: $tourName');
  } catch (e) {
    log.e('Error al guardar el tour: $e');
  }
}


  Future<void> _handleLoadTourFromSaved(LoadTourFromSavedEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final savedTour = await ecoCityTourRepository.getTourById(event.documentId);
      if (savedTour != null) {
        emit(state.copyWith(ecoCityTour: savedTour, isLoading: false));
        await mapBloc.drawEcoCityTour(savedTour);
      } else {
        emit(state.copyWith(hasError: true, isLoading: false));
      }
    } catch (error) {
      _handleError(error, emit);
    }
  }

  void _handleError(dynamic error, Emitter<TourState> emit) {
    log.e('Error: $error', error: error);
    emit(state.copyWith(hasError: true, isLoading: false));
  }
}
