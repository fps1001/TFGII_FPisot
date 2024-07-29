import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> {

  StreamSubscription? _gpsSubscription; // Para cerrar el stream

  GpsBloc()
      : super(const GpsState(
            isGpsEnabled: false, isGpsPermissionGranted: false)) {
    on<OnGpsAndPermissionEvent>((event,
            emit) // Se dispara al recibir un evento de tipo OnGpsAndPermissionEvent
        =>
        emit(state.copyWith(
          isGpsEnabled: event.isGpsEnabled, // Cambia el estado del GPS
          isGpsPermissionGranted:
              event.isGpsPermissionGranted, // Cambia el estado de los permisos
        )));
    _init(); // Se llama a la función obtención de los estados del GPS y los permisos
  }

  Future<void> _init() async {
    // Aquí se simula la obtención de los estados del GPS y los permisos
    final isEnable = await _checkGpsStatus(); // Se comprueba el estado del GPS
    _checkGpsStatus(); // Se comprueba el estado del GPS

    //Emitir el nuevo estado
    add(OnGpsAndPermissionEvent(
        isGpsEnabled: isEnable,
        isGpsPermissionGranted: state
            .isGpsPermissionGranted)); //Mando los dos estados, el permiso del gps será el actual.
  }

  Future<bool> _checkGpsStatus() async {
    final isEnable = await Geolocator
        .isLocationServiceEnabled(); //usando la librería geolocator se comprueba si el GPS está habilitado

    _gpsSubscription = Geolocator.getServiceStatusStream().listen((event) {
      //print('service status $event');
      final isEnabled =
          (event.index == 1) ? true : false; // Se obtiene el estado del GPS
      add(OnGpsAndPermissionEvent(
          isGpsEnabled: isEnabled,
          isGpsPermissionGranted: state.isGpsPermissionGranted));
    });

    return isEnable;
  }

  @override
  Future<void> close() {
    _gpsSubscription?.cancel(); // Se cancela la suscripción al stream
    return super.close();
  }
}
