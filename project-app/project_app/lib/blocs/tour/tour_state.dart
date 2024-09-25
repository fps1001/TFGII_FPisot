part of 'tour_bloc.dart';

class TourState extends Equatable {
  final List<PointOfInterest> pois;
  final bool isLoading;
  final bool hasError;

  const TourState({
    this.pois = const [],
    this.isLoading = false,
    this.hasError = false,
  });

  TourState copyWith({
    List<PointOfInterest>? pois,
    bool? isLoading,
    bool? hasError,
  }) {
    return TourState(
      pois: pois ?? this.pois,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object> get props => [pois, isLoading, hasError];
}
