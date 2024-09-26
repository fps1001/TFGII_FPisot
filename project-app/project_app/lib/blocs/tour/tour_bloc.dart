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
      //TODO Llamar al servicio de Places para actualizar los datos.
      // 2. Llamar al servicio de Places para mejorar los datos de cada POI
    // 2. Llamar al servicio de Places para mejorar los datos de cada POI
// 2. Llamar al servicio de Places para mejorar los datos de cada POI
    List<PointOfInterest> updatedPois = [];
    for (PointOfInterest poi in pois) {
      final placeData = await PlacesService().searchPlace(poi.name, event.city);

      // Si el servicio de Places devuelve datos, actualizamos el POI con la nueva información
      if (placeData != null) {
        final location = placeData['location'];
        final updatedPoi = PointOfInterest(
          // Acceder correctamente a las coordenadas
          gps: location != null
              ? LatLng(location['lat']?.toDouble() ?? poi.gps.latitude, // location['lat']
                      location['lng']?.toDouble() ?? poi.gps.longitude) // location['lng']
              : poi.gps,
          
          // Acceder correctamente a displayName (sin subcampo 'text')
          name: placeData['displayName'] ?? poi.name,
          
          // Verificar si los campos contienen valores antes de acceder
          description: placeData['editorialSummary']?['text'] ?? poi.description,
          url: placeData['websiteUri'] ?? poi.url,
          
          // Verificar si hay fotos y construir la URL
          imageUrl: placeData['photos'] != null && placeData['photos'].isNotEmpty
              ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${placeData['photos'][0]['name']}&key=YOUR_GOOGLE_API_KEY'
              : poi.imageUrl,
          
          // Verificar si el rating no es null y convertirlo a double si existe
          rating: placeData['rating'] != null ? placeData['rating'].toDouble() : null,
        );
        updatedPois.add(updatedPoi);
      } else {
        // Si no se encuentra información adicional, agregamos el POI original
        updatedPois.add(poi);
      }
    }

      // 3. Llamar al servicio de optimización de rutas.
      final List<LatLng> poiLocations = pois.map((poi) => poi.gps).toList();
      final optimizedRoute = await optimizationService.getOptimizedRoute(
        poiLocations,
        event.mode, // Se utiliza `event.mode` correctamente
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
