part of 'tour_bloc.dart';

sealed class TourEvent extends Equatable {
  const TourEvent();

  @override
  List<Object> get props => [];
}

class LoadTourEvent extends TourEvent {
  final String city;
  final int numberOfSites;
  final List<String> userPreferences;
  final String mode; 

  const LoadTourEvent({
    required this.city,
    required this.numberOfSites,
    required this.userPreferences,
    required this.mode, 
  });

  @override
  List<Object> get props => [city, numberOfSites, userPreferences, mode];
}
