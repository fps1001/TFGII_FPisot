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
  final double maxTime;

  const LoadTourEvent(
      {required this.city,
      required this.numberOfSites,
      required this.userPreferences,
      required this.mode,
      required this.maxTime});

  @override
  List<Object> get props =>
      [city, numberOfSites, userPreferences, mode, maxTime];
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
  final bool shouldUpdateMap; // Añadimos un booleano para actualizar el mapa o no en función de donde se emita.

  const OnRemovePoiEvent({required this.poi, this.shouldUpdateMap = true});

  @override
  List<Object> get props => [poi];
}

// Evento para indicar que el usuario se ha unido al tour.
class OnJoinTourEvent extends TourEvent {
  const OnJoinTourEvent();

  @override
  List<Object> get props => [];
}

// Evento para resetear el tour al volver a pantalla de carga.
class ResetTourEvent extends TourEvent {
  const ResetTourEvent();

  @override
  List<Object> get props => [];
}

// Evento para cargar los tours guardados después de eliminar uno.
class LoadSavedToursEvent extends TourEvent {
  const LoadSavedToursEvent();

  @override
  List<Object> get props => [];
}

// Inicializa el tour cuando se carga desde la pantalla de tours guardados
// sin haber cargado un tour previamente.
class LoadTourFromSavedEvent extends TourEvent {
  final String documentId;

  const LoadTourFromSavedEvent({required this.documentId});

  @override
  List<Object> get props => [documentId];
}
