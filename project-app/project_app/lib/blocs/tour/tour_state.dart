part of 'tour_bloc.dart';

class TourState extends Equatable {
  final EcoCityTour? ecoCityTour;
  final List<EcoCityTour> savedTours;
  final bool isLoading;
  final bool hasError;
  final bool isJoined;

  const TourState({
    this.ecoCityTour,
    this.savedTours = const [],
    this.isLoading = false,
    this.hasError = false,
    this.isJoined = false,
  });

  TourState copyWith({
    EcoCityTour? ecoCityTour,
    List<EcoCityTour>? savedTours,
    bool? isLoading,
    bool? hasError,
    bool? isJoined,
  }) {
    return TourState(
      savedTours: savedTours ?? this.savedTours,
      ecoCityTour: ecoCityTour ?? this.ecoCityTour,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  TourState copyWithNull() {
    return const TourState(
      ecoCityTour: null,
    );
  }

  @override
  List<Object?> get props => [ecoCityTour, savedTours, isLoading, hasError, isJoined];
}
