import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Mock de los servicios
class MockOptimizationService extends Mock implements OptimizationService {}

class MockMapBloc extends Mock implements MapBloc {}

// Definición correcta de MockGeminiService sin @override y con el valor simulado
class MockGeminiService extends Mock implements GeminiService {
  Future<List<PointOfInterest>> fetchGeminiData({
    required String city,
    required int nPoi,
    required List<String> userPreferences,
    required double maxTime,
    required String mode,
  }) {
    return Future.value(<PointOfInterest>[]); // Simulación del valor de retorno
  }
}

class MockPlacesService extends Mock implements PlacesService {}

void main() {
  late TourBloc tourBloc;
  late MockOptimizationService mockOptimizationService;
  late MockMapBloc mockMapBloc;
  late MockGeminiService mockGeminiService;

  setUp(() {
    mockOptimizationService = MockOptimizationService();
    mockMapBloc = MockMapBloc();
    mockGeminiService = MockGeminiService();

    tourBloc = TourBloc(
      optimizationService: mockOptimizationService,
      mapBloc: mockMapBloc,
    );

    // Registrar LatLng como valor predeterminado
    registerFallbackValue(const LatLng(0, 0));

    // Stub del método fetchGeminiData
    when(() => mockGeminiService.fetchGeminiData(
          city: any(named: 'city'),
          nPoi: any(named: 'nPoi'),
          userPreferences: any(named: 'userPreferences'),
          maxTime: any(named: 'maxTime'),
          mode: any(named: 'mode'),
        )).thenAnswer((_) async => <PointOfInterest>[]);
  });

  group('TourBloc Tests', () {
    // Prueba del evento LoadTourEvent
    blocTest<TourBloc, TourState>(
      'emits [TourState(isLoading: true, hasError: false), TourState(ecoCityTour: ..., isLoading: false)] when LoadTourEvent is added and succeeds',
      setUp: () {
        // Configuramos el mock del servicio de optimización para devolver una ruta
        when(() => mockOptimizationService.getOptimizedRoute(
              pois: any(named: 'pois'),
              mode: any(named: 'mode'),
              city: any(named: 'city'),
              userPreferences: any(named: 'userPreferences'),
            )).thenAnswer((_) async => EcoCityTour(
              city: 'Test City',
              pois: [],
              mode: 'walking',
              userPreferences: ['nature'],
              polilynePoints: [], // Proporcionar puntos de polilínea vacíos para el test
              duration: 1200, // Opcional
              distance: 5000, // Opcional
            ));
      },
      build: () => tourBloc,
      act: (bloc) => bloc.add(const LoadTourEvent(
        city: 'Test City',
        numberOfSites: 5,
        userPreferences: ['nature', 'culture'],
        mode: 'walking',
        maxTime: 120.0,
      )),
      expect: () => [
        const TourState(isLoading: true, hasError: false),
        TourState(
          isLoading: false,
          ecoCityTour: EcoCityTour(
            city: 'Test City',
            pois: [],
            mode: 'walking',
            userPreferences: ['nature', 'culture'],
            polilynePoints: [], // Debe estar presente
            duration: 1200,
            distance: 5000,
          ),
        ),
      ],
      verify: (_) {
        verify(() => mockGeminiService.fetchGeminiData(
              city: 'Test City',
              nPoi: 5,
              userPreferences: ['nature', 'culture'],
              maxTime: 120.0,
              mode: 'walking',
            )).called(1);
        verify(() => mockOptimizationService.getOptimizedRoute(
              pois: any(named: 'pois'),
              mode: 'walking',
              city: 'Test City',
              userPreferences: ['nature', 'culture'],
            )).called(1);
      },
    );

    // Prueba del evento OnAddPoiEvent
    blocTest<TourBloc, TourState>(
      'emits updated tour with new POI when OnAddPoiEvent is added',
      setUp: () {
        final ecoCityTour = EcoCityTour(
          city: 'Test City',
          pois: [],
          mode: 'walking',
          userPreferences: ['culture'],
          polilynePoints: [],
        );

        tourBloc.emit(TourState(ecoCityTour: ecoCityTour));
      },
      build: () => tourBloc,
      act: (bloc) => bloc.add(OnAddPoiEvent(
        poi: PointOfInterest(
          name: 'New POI',
          gps: const LatLng(0, 0),
          description: 'A new point of interest',
        ),
      )),
      expect: () => [
        TourState(isLoading: true, ecoCityTour: any(named: 'ecoCityTour')),
        isA<TourState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.ecoCityTour!.pois.length, 'pois count', 1),
      ],
      verify: (_) {
        verify(() => mockMapBloc.add(OnAddPoiMarkerEvent(any()))).called(1);
      },
    );

    // Prueba del evento ResetTourEvent
    blocTest<TourBloc, TourState>(
      'emits TourState with ecoCityTour null when ResetTourEvent is added',
      build: () => tourBloc,
      act: (bloc) => bloc.add(const ResetTourEvent()),
      expect: () => [
        const TourState(ecoCityTour: null, isJoined: false),
      ],
      verify: (_) {
        // Verifica que el evento OnClearMapEvent fue añadido al MapBloc
        verify(() => mockMapBloc.add(OnClearMapEvent())).called(1);
      },
    );
  });
}
