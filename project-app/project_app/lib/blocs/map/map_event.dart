part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

// Evento que se dispara cuando el mapa ha sido inicializado y recibimos el controlador del mapa.
class OnMapInitializedEvent extends MapEvent {
  final GoogleMapController mapController;
  //Ahora añadimos el contexto del mapa para ser pasado al estado.
  final BuildContext mapContext;

  const OnMapInitializedEvent(this.mapController, this.mapContext);

  @override
  List<Object> get props => [mapController, mapContext]; // Aseguramos que el contexto se compare correctamente.
}

// Evento para detener el seguimiento de la ubicación del usuario.
class OnStopFollowingUserEvent extends MapEvent {}

// Evento para iniciar el seguimiento de la ubicación del usuario.
class OnStartFollowingUserEvent extends MapEvent {}

// Evento para actualizar las polilíneas de la ruta del usuario.
class OnUpdateUserPolylinesEvent extends MapEvent {
  final List<LatLng> userLocations;

  const OnUpdateUserPolylinesEvent(this.userLocations);

  @override
  List<Object> get props => [userLocations];
}

// Evento para alternar la visibilidad de la ruta del usuario.
class OnToggleShowUserRouteEvent extends MapEvent {}

// Evento para mostrar nuevas polilíneas y marcadores en el mapa.
class OnDisplayPolylinesEvent extends MapEvent {
  final Map<String, Polyline> polylines;
  final Map<String, Marker> markers;

  const OnDisplayPolylinesEvent(this.polylines, this.markers);

  @override
  List<Object> get props => [polylines, markers];
}

// Evento para eliminar un marcador de POI
class OnRemovePoiMarkerEvent extends MapEvent {
  final String poiName;

  const OnRemovePoiMarkerEvent(this.poiName);

  @override
  List<Object> get props => [poiName];
}

// Evento para añadir un marcador en el mapa
class OnAddPoiMarkerEvent extends MapEvent {
  final PointOfInterest poi; // Información del POI que se añadirá como marcador

  const OnAddPoiMarkerEvent(this.poi);

  @override
  List<Object> get props => [poi];
}

// Definir el nuevo evento que se dispara cuando se limpia el mapa
class OnClearMapEvent extends MapEvent {}

