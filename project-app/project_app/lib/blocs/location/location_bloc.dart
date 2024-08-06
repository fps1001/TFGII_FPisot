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
    on<LocationEvent>((event, emit) {
      // TODO: implement event handler
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
      print('position: $position');
    });
  }

  void stopFollowingUser() {
    positionStream?.cancel();
    print('stopFollowingUser');
  }

  @override
  Future<void> close() {
    stopFollowingUser(); // Puede que no lo tengamos.
    return super.close();
  }
}
