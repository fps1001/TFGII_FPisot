import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_app/logger/logger.dart'; // Importamos logger para usarlo

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> {
  StreamSubscription? _gpsSubscription; // Para cerrar el stream

  GpsBloc()
      : super(const GpsState(
            isGpsEnabled: false, isGpsPermissionGranted: false)) {
    // Se dispara al recibir un evento de tipo OnGpsAndPermissionEvent
    on<OnGpsAndPermissionEvent>((event, emit) {
      log.i(
          'GpsBloc: Recibido evento OnGpsAndPermissionEvent - GPS habilitado: ${event.isGpsEnabled}, Permisos: ${event.isGpsPermissionGranted}');
      emit(state.copyWith(
        isGpsEnabled: event.isGpsEnabled, // Cambia el estado del GPS
        isGpsPermissionGranted:
            event.isGpsPermissionGranted, // Cambia el estado de los permisos
      ));
    });

    _init(); // Se llama a la función para obtener el estado del GPS y los permisos
  }

  Future<void> _init() async {
    try {
      log.i('GpsBloc: Inicializando estado del GPS y permisos.');
      // Se obtienen los estados del GPS y los permisos
      final gpsInitStatus =
          await Future.wait([checkGpsStatus(), isPermissionGranted()]);

      log.d(
          'GpsBloc: Estado inicial - GPS habilitado: ${gpsInitStatus[0]}, Permisos concedidos: ${gpsInitStatus[1]}');

      // Emitir el nuevo estado
      add(OnGpsAndPermissionEvent(
          isGpsEnabled: gpsInitStatus[0], // Mando el estado del GPS
          isGpsPermissionGranted:
              gpsInitStatus[1])); // Mando el estado de los permisos
    } catch (e, stackTrace) {
      log.e('GpsBloc: Error al inicializar GPS o permisos',
          error: e, stackTrace: stackTrace);
    }
  }

  // Se comprueba si el permiso de localización está concedido
  Future<bool> isPermissionGranted() async {
    try {
      final isGranted = await Permission.location.isGranted;
      log.d('GpsBloc: Permiso de localización concedido: $isGranted');
      return isGranted;
    } catch (e, stackTrace) {
      log.e('GpsBloc: Error al comprobar los permisos de localización',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Se comprueba si el GPS está habilitado
  Future<bool> checkGpsStatus() async {
    try {
      final isEnable = await Geolocator.isLocationServiceEnabled();
      log.d('GpsBloc: GPS habilitado: $isEnable');

      // Usando la librería geolocator se obtiene el stream del estado del GPS
      _gpsSubscription = Geolocator.getServiceStatusStream().listen((event) {
        final isEnabled =
            (event.index == 1) ? true : false; // Se obtiene el estado del GPS
        log.d('GpsBloc: Cambió el estado del GPS - Habilitado: $isEnabled');
        add(OnGpsAndPermissionEvent(
            isGpsEnabled: isEnabled,
            isGpsPermissionGranted: state.isGpsPermissionGranted));
      });

      return isEnable;
    } catch (e, stackTrace) {
      log.e('GpsBloc: Error al verificar el estado del GPS',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Se solicita el permiso de localización al usuario
  Future<void> askGpsAccess() async {
    try {
      final status = await Permission.location
          .request(); // Se solicita el permiso de localización al usuario
      log.i('GpsBloc: Solicitando acceso al GPS, estado: $status');

      switch (status) {
        case PermissionStatus.granted:
          log.i('GpsBloc: Permiso de GPS concedido.');
          add(OnGpsAndPermissionEvent(
              isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: true));
          break;
        case PermissionStatus.denied:
        case PermissionStatus.restricted:
        case PermissionStatus.permanentlyDenied:
          log.w('GpsBloc: Permiso de GPS denegado o restringido.');
          add(OnGpsAndPermissionEvent(
              isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: false));
          openAppSettings(); // Se abre la configuración de la app para que el usuario pueda dar permisos
          break;
        default:
          break;
      }
    } catch (e, stackTrace) {
      log.e('GpsBloc: Error al solicitar acceso al GPS',
          error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> close() {
    log.i('GpsBloc: Cerrando GpsBloc y cancelando suscripciones.');
    _gpsSubscription?.cancel(); // Se cancela la suscripción al stream
    return super.close();
  }
}
