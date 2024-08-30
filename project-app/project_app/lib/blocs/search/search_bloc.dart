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

  SearchBloc({required this.trafficService}) : super(const SearchState()) {
    on<OnActivateManualMarkerEvent>(
        (event, emit) => emit(state.copyWith(displayManualMarker: true)));
    on<OnDisactivateManualMarkerEvent>(
        (event, emit) => emit(state.copyWith(displayManualMarker: false)));
  }

  Future<RouteDestination> getCoorsStartToEnd(LatLng start, LatLng end) async {
    final resp = await trafficService.getCoorsStartToEnd(start, end);

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
        points: latLngList, duration: duration, distance: distance);
  }

  Future getPlacesByQuery(LatLng proximity, String query) async {
    final resp = trafficService.getResultsByQuery(proximity, query);

    //TODO: almacenar el state.
  }
}
