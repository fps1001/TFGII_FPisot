part of 'gps_bloc.dart';

class GpsState extends Equatable {
  final bool isGpsEnabled; // Indica si el GPS está activado
  final bool
      isGpsPermissionGranted; // Indica si la aplicación tiene permisos para acceder al GPS

  bool get isAllReady =>
      isGpsEnabled &&
      isGpsPermissionGranted; //Getter de estado correcto de permisos y GPS activo.

  const GpsState({
    required this.isGpsEnabled,
    required this.isGpsPermissionGranted,
  });

  GpsState copyWith({
    //En vez de crear otro estado, copio el actual y así sé cómo se encontraba y cambio lo que necesite
    bool? isGpsEnabled,
    bool? isGpsPermissionGranted,
  }) =>
      GpsState(
        // Función de flecha es un return implícito
        isGpsEnabled: isGpsEnabled ??
            this.isGpsEnabled, //Si no se especifica el valor, se mantiene el actual
        isGpsPermissionGranted: isGpsPermissionGranted ??
            this.isGpsPermissionGranted, //Si no se especifica el valor, se mantiene el actual
      );

  @override
  List<Object> get props => [isGpsEnabled, isGpsPermissionGranted];

  @override
  String toString() {
    return 'GpsState(isGpsEnabled: $isGpsEnabled, isGpsPermissionGranted: $isGpsPermissionGranted)';
  }
}
