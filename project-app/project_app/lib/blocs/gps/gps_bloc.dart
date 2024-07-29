import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> {
  GpsBloc() : super(const GpsState(isGpsEnabled: false, isGpsPermissionGranted: false)) {
    
    on<OnGpsAndPermissionEvent>((event, emit)  // Se dispara al recibir un evento de tipo OnGpsAndPermissionEvent
      => emit(state.copyWith( 
        isGpsEnabled: event.isGpsEnabled, // Cambia el estado del GPS
        isGpsPermissionGranted: event.isGpsPermissionGranted, // Cambia el estado de los permisos
      ))
    );
  }
}
