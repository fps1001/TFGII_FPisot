part of 'search_bloc.dart';

class SearchState extends Equatable {
  // Determinará si debe mostrar los widgets de búsqueda manual
  final bool displayManualMarker;

  const SearchState({this.displayManualMarker = false});

  SearchState copyWith({bool? displayManualMarker}) => SearchState(
      displayManualMarker: displayManualMarker ?? this.displayManualMarker);

  @override
  List<Object?> get props => [displayManualMarker];
}
