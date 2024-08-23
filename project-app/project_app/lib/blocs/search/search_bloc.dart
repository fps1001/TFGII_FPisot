import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/services/services.dart';

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
  Future getCoorsStartToEnd(LatLng start, LatLng end) async {
    // resp es de tipo del modelo del servicio: TrafficResponse
    final resp = await trafficService.getCoorsStartToEnd(start, end);

    return resp;
  }
}
