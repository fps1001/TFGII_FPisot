import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/services.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  //Traffic service: para calcular rutas
  TrafficService trafficService;

  SearchBloc({required this.trafficService}) : super(const SearchState()) {
    on<OnActivateManualMarkerEvent>(
        (event, emit) => emit(state.copyWith(displayManualMarker: true)));
    on<OnDisactivateManualMarkerEvent>(
        (event, emit) => emit(state.copyWith(displayManualMarker: false)));
  }

  // Se llamará cuando confirme destino
  // En el futuro será al activar o desactivar marcadores o al indicar una destino
  Future<RouteDestination> getCoorsStartToEnd(LatLng start, LatLng end) async {
    // resp es de tipo del modelo del servicio: TrafficResponse
    final resp = await trafficService.getCoorsStartToEnd(start, end);

    // Transformamos la petición en el tipo del modelo de routeDestination:

    final distance = resp.routes[0].distance;
    final duration = resp.routes[0].duration;
    final geometry = resp.routes[0].geometry;

    // Decodificar polyline6 en pares de valores (latlong) usando google_polyline_algorithm. Mapbox trabaja con 6 decimales
    final points = decodePolyline(geometry, accuracyExponent: 6);
    //La lista de lista de doubles se transforman en latlong:
    final latLngList = points
        .map((coor) => LatLng(coor[0].toDouble(), coor[1].toDouble()))
        .toList();

    return RouteDestination(
        points: latLngList, duration: duration, distance: distance);
  }
}
