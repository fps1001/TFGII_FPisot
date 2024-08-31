part of 'search_bloc.dart';

class SearchState extends Equatable {
  // Determinará si debe mostrar los widgets de búsqueda manual
  final bool displayManualMarker;
  // Lista de lugares encontrados
  final List<Feature> places;

  const SearchState({this.displayManualMarker = false, this.places = const []}); 

  SearchState copyWith({bool? displayManualMarker, List<Feature>? places})
   => SearchState(
      displayManualMarker: displayManualMarker ?? this.displayManualMarker,
      places: places ?? this.places);

  @override
  List<Object?> get props => [displayManualMarker, places];
}
