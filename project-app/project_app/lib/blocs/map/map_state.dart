part of 'map_bloc.dart';

class MapState extends Equatable {
  final bool isMapInitialized;
  final bool isFollowingUser;
  final bool showUserRoute;

  /*Polilíneas de rutas
   Son así:
   'nombre_ruta': {
      id: polylineId Google,
      points: [lat,lng], [2312][213213],
      width: 5,
      color: Colors.red,
   }
  */

  final Map<String, Polyline> polylines;

  const MapState( {
    this.isMapInitialized = false,
    this.isFollowingUser = true,
    this.showUserRoute = false,
    Map<String, Polyline>? polylines,
  }) : polylines = polylines ?? const {};

  MapState copyWith({
    // Indica si el mapa se puede usar.
    bool? isMapInitialized,
    // Indica si el mapa sigue al usuario.
    bool? isFollowingUser,
    // Indica si se muestra la ruta del usuario.
    bool? showUserRoute,
    // Polilíneas de rutas
    Map<String, Polyline>? polylines,
    
  }) =>
      MapState(
        isMapInitialized: isMapInitialized ?? this.isMapInitialized,
        isFollowingUser: isFollowingUser ?? this.isFollowingUser,
        showUserRoute: showUserRoute ?? this.showUserRoute,
        polylines: polylines ?? this.polylines,
        
      );

  @override
  List<Object> get props => [isMapInitialized, isFollowingUser, showUserRoute, polylines];
}
