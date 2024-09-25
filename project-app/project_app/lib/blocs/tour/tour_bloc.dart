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
      // Llama al servicio para obtener los datos
      final pois = await GeminiService.fetchGeminiData(
        city: event.city,
        nPoi: event.numberOfSites,
        userPreferences: event.userPreferences,
      );

      // Crea la instancia de EcoCityTour con los datos recibidos
      final ecoCityTour = EcoCityTour(
        city: event.city,
        numberOfSites: pois.length,
        pois: pois,
        mode: 'walking',  // Puedes ajustarlo según sea necesario
        userPreferences: event.userPreferences,
      );

      // Emite el estado con el tour completo cargado
      emit(state.copyWith(ecoCityTour: ecoCityTour, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }
}
