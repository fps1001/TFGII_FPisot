part of 'tour_bloc.dart';

class TourState extends Equatable {
  final EcoCityTour? ecoCityTour;
  final bool isLoading;
  final bool hasError;
  final bool isJoined;

  const TourState({
    this.ecoCityTour,
    this.isLoading = false,
    this.hasError = false,
    this.isJoined = false,
  });

  TourState copyWith({
    EcoCityTour? ecoCityTour,
    bool? isLoading,
    bool? hasError,
    bool? isJoined,
  }) {
    return TourState(
      ecoCityTour: ecoCityTour ?? this.ecoCityTour,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  @override
  List<Object?> get props => [ecoCityTour, isLoading, hasError, isJoined];
}
