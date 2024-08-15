import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  // Opcional porque al iniciar no existe.
  GoogleMapController? _mapController;

  MapBloc() : super(const MapState()) {
    // Cuando recibo un evento de tipo OnMapInitializedEvent emite un nuevo estado.
    // Lo voy a pasar a una función:
    //on<OnMapInitializedEvent>((event, emit) => emit(state.copyWith(isMapInitialized: true)));

    on<OnMapInitializedEvent>(_onInitMap);
  }

  void _onInitMap(OnMapInitializedEvent event, Emitter<MapState> emit) {
    {
      _mapController = event.mapController;

      //Añado estilo al mapa
      // Deprecated
      //_mapController!.setMapStyle(jsonEncode(retroMapTheme));
      emit(state.copyWith(isMapInitialized: true));
    }
  }

  void moveCamera (LatLng latLng){
    _mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
  }
}
