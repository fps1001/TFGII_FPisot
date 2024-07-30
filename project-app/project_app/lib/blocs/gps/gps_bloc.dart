import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
  
    final gpsInitStatus = await Future.wait(_checkGpsStatus(), _isPermissionGranted()); // Se obtienen los estados del GPS y los permisos

    //Emitir el nuevo estado
    add(OnGpsAndPermissionEvent(
        isGpsEnabled: gpsInitStatus[0], //Mando el estado del GPS
        isGpsPermissionGranted: gpsInitStatus[1])); //Mando el estado de los permisos
  }
  
  Future<bool> _isPermissionGranted() async { // Se comprueba si el permiso de localización está concedido
    final isGranted = await Permission.location.isGranted;
    return isGranted;
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


  Future <void> askGpsAccess() async {
    final status = await Permission.location.request(); // Se solicita el permiso de localización al usuario

    switch (status){
      case PermissionStatus.granted:
        add(OnGpsAndPermissionEvent(isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: true));
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
        add(OnGpsAndPermissionEvent(isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: false));
        openAppSettings(); // Se abre la configuración de la app para que el usuario pueda dar permisos
        // Este método ya viene en el paquete.
        break;
      default:
        break;
    }        

  }

  @override
  Future<void> close() {
    _gpsSubscription?.cancel(); // Se cancela la suscripción al stream
    return super.close();
  }
}
