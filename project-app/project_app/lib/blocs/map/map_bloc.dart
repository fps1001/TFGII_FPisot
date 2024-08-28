import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/models/models.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  // Opcional porque al iniciar no existe.
  GoogleMapController? _mapController;
  // Añado bloc de localización
  final LocationBloc locationBloc;
  StreamSubscription<LocationState>? locationSubscription;

  LatLng? mapCenter;

  MapBloc({required this.locationBloc}) : super(const MapState()) {
    // Cuando recibo un evento de tipo OnMapInitializedEvent emite un nuevo estado.
    on<OnMapInitializedEvent>(_onInitMap);
    // Cuando recibo un evento de tipo OnStartFollowingUserEvent emite un nuevo estado.
    on<OnStartFollowingUserEvent>(_onStartFollowingUser);
    // Cuando recibo un evento de tipo OnStopFollowingUserEvent emite un nuevo estado.
    on<OnStopFollowingUserEvent>(
        (event, emit) => emit(state.copyWith(isFollowingUser: false)));
    // Cuando recibo un evento de tipo OnUpdateUserPolylinesEvent emite un nuevo estado.
    on<OnUpdateUserPolylinesEvent>(_onPolylineNewPoint);
    // Cuando recibo una nueva polilínea a dibujar emite un nuevo estado al que le pasa la nueva polilínea.
    on<OnDisplayPolylinesEvent>(
        (event, emit) => emit(state.copyWith(polylines: event.polylines)));

    // Cuando recibo un evento de tipo OnToggleShowUserRouteEvent emite un nuevo estado.
    on<OnToggleShowUserRouteEvent>((event, emit) =>
        emit(state.copyWith(showUserRoute: !state.showUserRoute)));

    // Suscripción al bloc de localización.
    locationSubscription = locationBloc.stream.listen((locationState) {
      // Llama al evento de añadir una polilínea al recorrido de usuario.
      if (locationState.lastKnownLocation != null) {
        add(OnUpdateUserPolylinesEvent(locationState.myLocationHistory));
      }

      // Saber si hay que mover la cámara.
      if (!state.isFollowingUser) return;
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

  // Metodo que recibe una polilínea y la emite en un nuevo evento.
  Future drawRoutePolyline(RouteDestination destination) async {
    final myRoute = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.teal,
      width: 5,
      points: destination.points,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    // Transformación de ruta para evento:
    // polilineas actuales. hay que copiarlas
    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    currentPolylines['route'] = myRoute;

    add(OnDisplayPolylinesEvent(currentPolylines));
  }

  void moveCamera(LatLng latLng) {
    final cameraUpdate = CameraUpdate.newLatLng(latLng);
    _mapController?.animateCamera(cameraUpdate);
  }

  //Función para que al tocar el botón se centre en el usuario sin esperar al cambio de localización.
  void _onStartFollowingUser(
      OnStartFollowingUserEvent event, Emitter<MapState> emit) {
    emit(state.copyWith(isFollowingUser: true));
    if (locationBloc.state.lastKnownLocation == null) return;
    moveCamera(locationBloc.state.lastKnownLocation!);
  }

  // Función para añadir un punto a una polilínea.
  void _onPolylineNewPoint(
      OnUpdateUserPolylinesEvent event, Emitter<MapState> emit) {
    // Se crea la nueva polilínea y se añade a las que ya había.
    final polylines = Map<String, Polyline>.from(state.polylines);
    final polyline = Polyline(
      polylineId: const PolylineId('user'),
      points: event.userLocations,
      width: 5,
      color: Colors.blue,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
    // crea una copia del estado actual y se añade la nueva polilínea.
    polylines['user'] = polyline;
    // Emite el nuevo estado.
    emit(state.copyWith(polylines: polylines));
  }

  @override
  Future<void> close() {
    locationSubscription?.cancel();
    return super.close();
  }
}
