part of 'location_bloc.dart';

class LocationState extends Equatable {
  final bool followingUser; //Determina si se está siguiendo al usuario.
  final LatLng? lastKnownLocation; // Al principio no la sé -> ?
  final List<LatLng> myLocationHistory;

  const LocationState(
      {this.followingUser = false, this.lastKnownLocation, myLocationHistory})
      : myLocationHistory = myLocationHistory ?? const [];

  LocationState copyWith({ // Para emitir un nuevo estado. Si existe copia sino toma el que había.
    bool? followingUser,
    LatLng? lastKnownLocation,
    List<LatLng>? myLocationHistory,
  }) =>
      LocationState(
          followingUser    : followingUser ?? this.followingUser,
          lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
          myLocationHistory: myLocationHistory ?? this.myLocationHistory);

  @override
  List<Object?> get props =>
      [followingUser, lastKnownLocation, myLocationHistory];
}
