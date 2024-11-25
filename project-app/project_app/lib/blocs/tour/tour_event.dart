part of 'tour_bloc.dart';

abstract class TourEvent extends Equatable {
  const TourEvent();

  @override
  List<Object> get props => [];
}

// Cargar un EcoCityTour.
class LoadTourEvent extends TourEvent {
  final String city;
  final int numberOfSites;
  final List<String> userPreferences;
  final String mode;
  final double maxTime;
  final String systemInstruction;

  const LoadTourEvent({
    required this.city,
    required this.numberOfSites,
    required this.userPreferences,
    required this.mode,
    required this.maxTime,
    required this.systemInstruction,
  });

  @override
  List<Object> get props => [city, numberOfSites, userPreferences, mode, maxTime];
}

// Añadir un POI.
class OnAddPoiEvent extends TourEvent {
  final PointOfInterest poi;

  const OnAddPoiEvent({required this.poi});

  @override
  List<Object> get props => [poi];
}

// Eliminar un POI.
class OnRemovePoiEvent extends TourEvent {
  final PointOfInterest poi;
  final bool shouldUpdateMap;

  const OnRemovePoiEvent({required this.poi, this.shouldUpdateMap = true});

  @override
  List<Object> get props => [poi, shouldUpdateMap];
}

// Unirse a un tour.
class OnJoinTourEvent extends TourEvent {
  const OnJoinTourEvent();

  @override
  List<Object> get props => [];
}

// Resetear el tour.
class ResetTourEvent extends TourEvent {
  const ResetTourEvent();

  @override
  List<Object> get props => [];
}

// Cargar tours guardados.
class LoadSavedToursEvent extends TourEvent {
  const LoadSavedToursEvent();

  @override
  List<Object> get props => [];
}

// Cargar un tour desde el repositorio guardado.
class LoadTourFromSavedEvent extends TourEvent {
  final String documentId;

  const LoadTourFromSavedEvent({required this.documentId});

  @override
  List<Object> get props => [documentId];
}

// Guardar el tour actual.
class SaveTourEvent extends TourEvent {
  final String tourName;

  const SaveTourEvent({required this.tourName});

  @override
  List<Object> get props => [tourName];
}
