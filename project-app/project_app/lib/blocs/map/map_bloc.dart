import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/blocs/blocs.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  // Opcional porque al iniciar no existe.
  GoogleMapController? _mapController;
  // Añado bloc de localización
  final LocationBloc locationBloc;

  MapBloc({required this.locationBloc}) : super(const MapState()) {
    // Cuando recibo un evento de tipo OnMapInitializedEvent emite un nuevo estado.
    on<OnMapInitializedEvent>(_onInitMap);

    // Suscripción al bloc de localización.
    locationBloc.stream.listen((locationState) {
      // Saber si hay que mover la cámara.
      if (!state.followUser) return;
      if (locationState.lastKnownLocation == null) return;
      
      moveCamera(locationState.lastKnownLocation!);
      
    });
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

  void moveCamera(LatLng latLng) {
    _mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
  }
}
