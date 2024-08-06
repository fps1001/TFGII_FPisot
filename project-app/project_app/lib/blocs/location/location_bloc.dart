import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription?
      positionStream; // Suscripción de posición, opcional hasta crear no existe.

  LocationBloc() : super(const LocationState()) {
    on<OnNewUserLocationEvent>((event, emit) {
      emit(state.copyWith(
          lastKnownLocation: event.newLocation,
          myLocationHistory: [
            ...state.myLocationHistory,
            event.newLocation
          ] //concatena a los que había la nueva ubicación.
          )); // emitir el nuevo estado
    });
  }

  /// Obtiene la posición actual del usuario.
  Future getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition();
    //print('position: $position');
    return LatLng(position.latitude, position.longitude);
  }

  /// Empieza a emitir los valores de posición del usuario.
  void startFollowingUser() {
    positionStream = Geolocator.getPositionStream().listen((event) {
      // Crea esta subscription que dará la posición.
      final position = event;
      add(OnNewUserLocationEvent(
          LatLng(position.latitude, position.longitude)));
    });
  }

  void stopFollowingUser() {
    positionStream?.cancel();
    //print('stopFollowingUser');
  }

  @override
  Future<void> close() {
    stopFollowingUser(); // Puede que no lo tengamos.
    return super.close();
  }
}
