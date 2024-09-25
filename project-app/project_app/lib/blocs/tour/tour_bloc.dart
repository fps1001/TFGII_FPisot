import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/services.dart';

part 'tour_event.dart';
part 'tour_state.dart';

class TourBloc extends Bloc<TourEvent, TourState> {
  

  TourBloc() : super(const TourState()) {
    on<LoadTourEvent>(_onLoadTour);
  }

  Future<void> _onLoadTour(LoadTourEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(isLoading: true, hasError: false));
    try {
      // Accede al método estático de la clase
      final pois = await GeminiService.fetchGeminiData(
        city: event.city,
        nPoi: event.numberOfSites,
        userPreferences: event.userPreferences,
      );
      emit(state.copyWith(pois: pois, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }
}
