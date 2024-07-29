part of 'gps_bloc.dart';

class GpsState extends Equatable {
  final bool isGpsEnabled; // Indica si el GPS está activado
  final bool
      isGpsPermissionGranted; // Indica si la aplicación tiene permisos para acceder al GPS

  const GpsState({
    required this.isGpsEnabled,
    required this.isGpsPermissionGranted,
  });

  @override
  List<Object> get props => [isGpsEnabled, isGpsPermissionGranted];

  @override
  String toString() {
    return 'GpsState(isGpsEnabled: $isGpsEnabled, isGpsPermissionGranted: $isGpsPermissionGranted)';
  }

}
