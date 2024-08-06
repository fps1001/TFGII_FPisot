part of 'location_bloc.dart';

@immutable
class LocationState extends Equatable {
  final bool followingUser; //Determina si se está siguiendo al usuario.
  //TODO
  //ultima geolocation
  //historia

  const LocationState({
    this.followingUser = false
  });

  @override
  List<Object> get props => [ followingUser ];
}
