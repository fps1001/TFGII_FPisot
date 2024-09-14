part of 'map_bloc.dart';

class MapState extends Equatable {
  final bool isMapInitialized;
  final bool isFollowingUser;
  final bool showUserRoute;


  final Map<String, Polyline> polylines;
  // De igual manera funcionan los marcadores
  final Map<String, Marker> markers;

  const MapState( {
    this.isMapInitialized = false,
    this.isFollowingUser = true,
    this.showUserRoute = false,
    Map<String, Polyline>? polylines,
    Map<String, Marker>? markers,
  }) : polylines = polylines ?? const {},
       markers = markers ?? const {};
  

  MapState copyWith({
    // Copiamos el estado actual del mapa.
    bool? isMapInitialized,
    bool? isFollowingUser,
    bool? showUserRoute,
    Map<String, Polyline>? polylines,
    Map<String, Marker>? markers,
    
  }) =>
      MapState(
        isMapInitialized: isMapInitialized ?? this.isMapInitialized,
        isFollowingUser: isFollowingUser ?? this.isFollowingUser,
        showUserRoute: showUserRoute ?? this.showUserRoute,
        polylines: polylines ?? this.polylines,
        markers : markers ?? this.markers,
        
      );

  @override
  List<Object> get props => [isMapInitialized, isFollowingUser, showUserRoute, polylines, markers];
}
