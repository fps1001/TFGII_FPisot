part of 'search_bloc.dart';

class SearchState extends Equatable {
  // Determinará si debe mostrar los widgets de búsqueda manual
  final bool displayManualMarker;
  // Lista de lugares encontrados
  final List<Feature> places;
  // Lista de historial de lugares visitados.
  final List<Feature> history;

  const SearchState({
    this.displayManualMarker = false, 
    this.places = const [],
    this.history = const [],
  }); 

  SearchState copyWith({bool? displayManualMarker, 
  List<Feature>? places, List<Feature>? history})
   => SearchState(
      displayManualMarker: displayManualMarker ?? this.displayManualMarker,
      places: places ?? this.places,
      history: history ?? this.history);

  @override
  List<Object?> get props => [displayManualMarker, places, history];
}
