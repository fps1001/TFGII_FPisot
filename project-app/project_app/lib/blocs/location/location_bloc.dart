import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription?
      positionStream; // Suscripción de posición, opcional hasta crear no existe.

  LocationBloc() : super(const LocationState()) {
    on<OnNewUserLocationEvent>((event, emit) {
      log.i(
          'LocationBloc: Nueva ubicación del usuario recibida: ${event.newLocation}');
      emit(state.copyWith(
          lastKnownLocation: event.newLocation,
          myLocationHistory: [
            ...state.myLocationHistory,
            event.newLocation
          ] //concatena a los que había la nueva ubicación.
          )); // emitir el nuevo estado
    });

    on<OnStartFollowingUser>((event, emit) {
      log.i('LocationBloc: Iniciado seguimiento de usuario');
      emit(state.copyWith(followingUser: true));
    });

    on<OnStopFollowingUser>((event, emit) {
      log.i('LocationBloc: Detenido seguimiento de usuario');
      emit(state.copyWith(followingUser: false));
    });
  }

  /// Obtiene la posición actual del usuario.
  Future<LatLng> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      log.i('LocationBloc: Posición actual obtenida: $position');
      return LatLng(position.latitude, position.longitude);
    } catch (e, stackTrace) {
      log.e('LocationBloc: Error obteniendo posición actual',
          error: e, stackTrace: stackTrace);
      rethrow; // Para manejar el error más arriba si es necesario.
    }
  }

  /// Empieza a emitir los valores de posición del usuario.
  void startFollowingUser() {
    add(OnStartFollowingUser());
    positionStream = Geolocator.getPositionStream().listen((event) {
      final position = event;
      log.d('LocationBloc: Nueva posición emitida: $position');
      add(OnNewUserLocationEvent(
          LatLng(position.latitude, position.longitude)));
    });
  }

  void stopFollowingUser() {
    log.i('LocationBloc: Deteniendo seguimiento de usuario');
    positionStream?.cancel();
    add(OnStopFollowingUser());
  }

  @override
  Future<void> close() {
    log.i('LocationBloc: Cerrando LocationBloc y cancelando suscripciones.');
    stopFollowingUser(); // Puede que no lo tengamos.
    return super.close();
  }
}