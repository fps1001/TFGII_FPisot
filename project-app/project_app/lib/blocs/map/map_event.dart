part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

// Recibe el controlador del mapa cuando se crea.
class OnMapInitializedEvent extends MapEvent {
  final GoogleMapController mapController;

  const OnMapInitializedEvent(this.mapController);
}

// Cambia el estado de seguir al usuario.
class OnStopFollowingUserEvent extends MapEvent {}

class OnStartFollowingUserEvent extends MapEvent {}

//Historial de locationBloc de movimientos de usuario
class OnUpdateUserPolylinesEvent extends MapEvent {
  final List<LatLng> userLocations;
  const OnUpdateUserPolylinesEvent(this.userLocations);
}

//Muestra la ruta del usuario o la oculta.
class OnToggleShowUserRouteEvent extends MapEvent {}

// Muestra una polilínea nueva:
class OnDisplayPolylinesEvent extends MapEvent {
  // Debe recibir lo mismo que user polylinesEvent pero con nuevo modelo:
  final Map<String, Polyline> polylines;
  // Constructor.
  const OnDisplayPolylinesEvent(this.polylines);
}
