part of 'map_bloc.dart';

abstract class MapEvent extends Equatable{
  const MapEvent();

  @override
  List<Object> get props => [];
}


// Recibe el controlador del mapa cuando se crea.
class OnMapInitializedEvent extends MapEvent {
  final GoogleMapController mapController;

  const OnMapInitializedEvent(this.mapController);

  @override
  List<Object> get props => [mapController];

}

// Cambia el estado de seguir al usuario.
class OnStopFollowingUserEvent extends MapEvent {}

class OnStartFollowingUserEvent extends MapEvent {}