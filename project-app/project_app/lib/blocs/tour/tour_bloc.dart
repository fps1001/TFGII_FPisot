import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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

    // 2. Extraer las ubicaciones de los POIs para optimizar la ruta.
    final List<LatLng> poiLocations = pois.map((poi) => poi.gps).toList();

    // 3. Llamar al servicio de optimización de rutas.
    final optimizedRoute = await optimizationService.getOptimizedRoute(
      poiLocations, 
      event.mode,  // Se utiliza `event.mode` correctamente
    );

    // 4. Crear la instancia de EcoCityTour con los datos obtenidos.
    final ecoCityTour = EcoCityTour(
      city: event.city,
      numberOfSites: pois.length,
      pois: pois,
      mode: event.mode, // Se pasa el `mode` al modelo
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
      } // Logging para ver los errores detallados
    }
    emit(state.copyWith(isLoading: false, hasError: true));
  }
}

}
