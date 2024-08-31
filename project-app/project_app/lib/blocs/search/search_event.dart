part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class OnActivateManualMarkerEvent extends SearchEvent {}

class OnDisactivateManualMarkerEvent extends SearchEvent {}

class OnNewPlacesFoundEvent extends SearchEvent {
  final List<Feature> places;
  OnNewPlacesFoundEvent({required this.places});

}
// Evento que añade un lugar al historial.
class OnAddToHistoryEvent extends SearchEvent {
  // place será el lugar a añadir al historial. será required.
  final Feature place;
  OnAddToHistoryEvent({required this.place});
}