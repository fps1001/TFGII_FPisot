
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/services.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

import '../../exceptions/exceptions.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final TrafficService trafficService;
  final OptimizationService optimizationService;
  // Manejadores de eventos a continuación
  SearchBloc({required this.trafficService, required this.optimizationService}) : super(const SearchState()) {
    on<OnActivateManualMarkerEvent>(
        (event, emit) => emit(state.copyWith(displayManualMarker: true)));
    on<OnDisactivateManualMarkerEvent>(
        (event, emit) => emit(state.copyWith(displayManualMarker: false)));
    // añado el evento OnNewPlacesFoundEvent que recibe una lista de lugares
    on<OnNewPlacesFoundEvent>(
        (event, emit) => emit(state.copyWith(places: event.places)));
    // añado el evento OnAddToHistoryEvent que añade un lugar al historial.
    on<OnAddToHistoryEvent>((event, emit) =>
        emit(state.copyWith(history: [event.place, ...state.history])));
  }

  Future<RouteDestination> getCoorsStartToEnd(LatLng start, LatLng end) async {
    final resp = await trafficService.getCoorsStartToEnd(start, end);

    // Información del destino
    final endPlace = await trafficService.getPlaceByCoords(end);

    // Información de la ruta
    final distance = resp.routes[0].distance;
    final duration = resp.routes[0].duration;
    final geometry = resp.routes[0].geometry;

    if (geometry.isEmpty) {
      throw AppException("No geometry found for route");
    }

    final points = decodePolyline(geometry, accuracyExponent: 6);

    final latLngList = points
        .map((coor) => LatLng(coor[0].toDouble(), coor[1].toDouble()))
        .toList();

    return RouteDestination(
        points: latLngList, 
        duration: duration, 
        distance: distance,
        endPlace: endPlace);
  }

  Future getPlacesByQuery(LatLng proximity, String query) async {
    // añado await para esperar la respuesta de la petición.
    final newPlaces = await trafficService.getResultsByQuery(proximity, query);

    add(OnNewPlacesFoundEvent(places: newPlaces));
  }

Future<RouteDestination> getOptimizedRoute(List<LatLng> waypoints) async {
  // Obtener la respuesta de la optimización de la ruta
  final resp = await optimizationService.getOptimizedRoute(waypoints);

  if (resp.trips.isEmpty) {
    throw AppException("No trips found in the optimization response");
  }

  List<LatLng> allPoints = [];
  double totalDistance = 0;
  double totalDuration = 0;

  // Recorremos todos los trips y concatenamos los puntos de cada uno
  for (var trip in resp.trips) {
    final geometry = trip.geometry;
    if (geometry.isEmpty) {
      throw AppException("No geometry found for one of the trips");
    }

    final points = decodePolyline(geometry, accuracyExponent: 6);
    final latLngList = points
        .map((coor) => LatLng(coor[0].toDouble(), coor[1].toDouble()))
        .toList();

    // Agregamos los puntos a la lista general
    allPoints.addAll(latLngList);

    // Sumamos distancia y duración totales
    totalDistance += trip.distance;
    totalDuration += trip.duration;
  }
  // Constuimos un RouteDestination que se puede pintar con los datos de los Trips:
  final endPlace = await trafficService.getPlaceByCoords(waypoints.last);
  // Retornar la ruta optimizada completa con todos los trips
  return RouteDestination(
    points: allPoints,
    duration: totalDuration,
    distance: totalDistance,
    endPlace: endPlace
  );
}


}
