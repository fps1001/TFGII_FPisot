part of 'map_bloc.dart';

class MapState extends Equatable {
  // Indica si el mapa ha sido inicializado o no.
  final bool isMapInitialized;

  // Indica si el mapa está siguiendo la ubicación del usuario.
  final bool isFollowingUser;

  // Indica si se debe mostrar la ruta del usuario o no.
  final bool showUserRoute;

  // Contiene las polilíneas (rutas) que se deben mostrar en el mapa.
  final Map<String, Polyline> polylines;

  // Contiene los marcadores que se deben mostrar en el mapa.
  final Map<String, Marker> markers;

  // El contexto del mapa, que nos permitirá mostrar un BottomSheet o interactuar con la UI desde el bloc.
  final BuildContext? mapContext;

  // Constructor de MapState.
  const MapState({
    this.mapContext, // El contexto puede ser nulo al inicio.
    this.isMapInitialized = false,
    this.isFollowingUser = false,
    this.showUserRoute = false,
    Map<String, Polyline>? polylines,
    Map<String, Marker>? markers,
  })  : polylines = polylines ?? const {}, // Inicializamos las polilíneas como un mapa vacío si no se pasa ningún valor.
        markers = markers ?? const {};     // Inicializamos los marcadores como un mapa vacío si no se pasa ningún valor.

  // Método que permite copiar el estado actual y reemplazar solo los valores que se deseen modificar.
  MapState copyWith({
    bool? isMapInitialized,
    bool? isFollowingUser,
    bool? showUserRoute,
    Map<String, Polyline>? polylines,
    Map<String, Marker>? markers,
    BuildContext? mapContext, // Añadimos la capacidad de copiar el contexto.
  }) =>
      MapState(
        mapContext: mapContext ?? this.mapContext, // Usamos el contexto actual si no se pasa uno nuevo.
        isMapInitialized: isMapInitialized ?? this.isMapInitialized,
        isFollowingUser: isFollowingUser ?? this.isFollowingUser,
        showUserRoute: showUserRoute ?? this.showUserRoute,
        polylines: polylines ?? this.polylines,
        markers: markers ?? this.markers,
      );

  @override
  List<Object?> get props => [
        isMapInitialized,
        isFollowingUser,
        showUserRoute,
        polylines,
        markers,
        mapContext, // Aseguramos que mapContext sea parte de la comparación de estados.
      ];
}
