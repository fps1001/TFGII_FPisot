part of 'map_bloc.dart';

class MapState extends Equatable {
  final bool isMapInitialized;
  final bool isFollowingUser;

  const MapState({
    this.isMapInitialized = false, 
    this.isFollowingUser = true
  });

  MapState copyWith({
    // Indica si el mapa se puede usar.
    bool? isMapInitialized,
    // Indica si el mapa sigue al usuario.
    bool? isFollowingUser,
  }) =>
      MapState(
        isMapInitialized: isMapInitialized ?? this.isMapInitialized,
        isFollowingUser: isFollowingUser ?? this.isFollowingUser,
      );

  @override
  List<Object> get props => [isMapInitialized, isFollowingUser];
}
