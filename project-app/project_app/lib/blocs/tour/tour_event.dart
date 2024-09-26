part of 'tour_bloc.dart';

abstract class TourEvent extends Equatable {
  const TourEvent();

  @override
  List<Object> get props => [];
}

// Evento que se dispara cuando se carga el EcoCityTour.
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

// Evento que se dispara cuando se añade un punto de interés al recorrido.
class OnAddPoiEvent extends TourEvent {
  final PointOfInterest poi;

  const OnAddPoiEvent({required this.poi});

  @override
  List<Object> get props => [poi];
}

// Evento que se dispara cuando se elimina un punto de interés del recorrido.
class OnRemovePoiEvent extends TourEvent {
  final PointOfInterest poi;

  const OnRemovePoiEvent({required this.poi});

  @override
  List<Object> get props => [poi];
}

