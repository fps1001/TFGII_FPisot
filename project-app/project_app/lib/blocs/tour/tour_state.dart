part of 'tour_bloc.dart';

class TourState extends Equatable {
  final EcoCityTour? ecoCityTour;
  final bool isLoading;
  final bool hasError;

  const TourState({
    this.ecoCityTour,
    this.isLoading = false,
    this.hasError = false,
  });

  TourState copyWith({
    EcoCityTour? ecoCityTour,
    bool? isLoading,
    bool? hasError,
  }) {
    return TourState(
      ecoCityTour: ecoCityTour ?? this.ecoCityTour,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props => [ecoCityTour, isLoading, hasError];
}
