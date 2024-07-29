part of 'gps_bloc.dart';

sealed class GpsEvent extends Equatable {
  const GpsEvent();

  @override
  List<Object> get props => [];
}

class OnGpsAndPermissionEvent extends GpsEvent { // Evento que se dispara cuando se comprueba si el GPS está activado y si la aplicación tiene permisos para acceder a él
  final bool isGpsEnabled;
  final bool isGpsPermissionGranted;

  const OnGpsAndPermissionEvent({
    required this.isGpsEnabled,
    required this.isGpsPermissionGranted,
  });
}
