import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/datasets/datasets.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/repositories/eco_city_tour_repository.dart';
import 'package:project_app/services/services.dart';

void main() {
  late LocationBloc locationBloc;
  late MapBloc mapBloc;
  late OptimizationService optimizationService;
  late EcoCityTourRepository ecoCityTourRepository;
  late FakeFirebaseFirestore fakeFirestore;

  const testUserId = 'testUser123';

  setUp(() async {
    // Configurar Firestore falso
    fakeFirestore = FakeFirebaseFirestore();

    // Configurar los servicios y blocs
    locationBloc = LocationBloc();
    mapBloc = MapBloc(locationBloc: locationBloc);
    optimizationService = OptimizationService();
    ecoCityTourRepository = EcoCityTourRepository(
      FirestoreDataset(userId: testUserId, firestore: fakeFirestore),
    );
  });

  tearDown(() async {
    await mapBloc.close();
    await locationBloc.close();
  });

  group('TourBloc Tests with fake Firestore', () {
    test('Initial state is TourState', () {
      final tourBloc = TourBloc(
        mapBloc: mapBloc,
        optimizationService: optimizationService,
        ecoCityTourRepository: ecoCityTourRepository,
      );
      expect(tourBloc.state, const TourState());
    });

    blocTest<TourBloc, TourState>(
  'removes a POI and updates the tour',
  build: () {
    final poi = PointOfInterest(
      gps: const LatLng(10.0, 10.0),
      name: 'Remove POI',
      description: 'A point to remove',
    );

    // Pre-configurar el estado inicial con un tour que tiene este POI
    return TourBloc(
      mapBloc: mapBloc,
      optimizationService: optimizationService,
      ecoCityTourRepository: ecoCityTourRepository,
    )..emit(TourState(ecoCityTour: EcoCityTour(
      city: 'Test City',
      mode: 'walking',
      userPreferences: ['Scenic'],
      polilynePoints: [const LatLng(0.0, 0.0)],
      pois: [poi],
    )));
  },
  act: (bloc) {
    final poiToRemove = PointOfInterest(
      gps: const LatLng(10.0, 10.0),
      name: 'Remove POI',
      description: 'A point to remove',
    );
    bloc.add(OnRemovePoiEvent(poi: poiToRemove));
  },
  wait: const Duration(milliseconds: 500),
  verify: (bloc) {
    final state = bloc.state;
    expect(state.ecoCityTour?.pois.any((poi) => poi.name == 'Remove POI'), false);
  },
);

blocTest<TourBloc, TourState>(
  'adds a POI and updates the tour',
  build: () {
    return TourBloc(
      mapBloc: mapBloc,
      optimizationService: optimizationService,
      ecoCityTourRepository: ecoCityTourRepository,
    );
  },
  act: (bloc) {
    final poi = PointOfInterest(
      gps: const LatLng(10.0, 10.0),
      name: 'New POI',
      description: 'A new point of interest',
    );
    bloc.add(OnAddPoiEvent(poi: poi));
  },
  wait: const Duration(milliseconds: 500),
  verify: (bloc) {
    final state = bloc.state;
    expect(state.ecoCityTour?.pois.any((poi) => poi.name == 'New POI'), true);
  },
);

    blocTest<TourBloc, TourState>(
      'saves and loads a tour from FirestoreDataset',
      build: () {
        return TourBloc(
          mapBloc: mapBloc,
          optimizationService: optimizationService,
          ecoCityTourRepository: ecoCityTourRepository,
        );
      },
      act: (bloc) async {
        final testTour = EcoCityTour(
          city: 'Saved City',
          mode: 'cycling',
          userPreferences: ['Adventure'],
          polilynePoints: [const LatLng(0.0, 0.0)],
          pois: [
            PointOfInterest(
              gps: const LatLng(0.0, 0.0),
              name: 'POI 1',
              description: 'A fun adventure spot',
            ),
          ],
        );

        // Guardar el tour
        bloc.emit(TourState(ecoCityTour: testTour));
        await bloc.saveCurrentTour('TestTour');

        // Cargar el tour guardado
        bloc.add(const LoadTourFromSavedEvent(documentId: 'TestTour'));
      },
      wait: const Duration(seconds: 1),
      verify: (bloc) async {
        final tours = await ecoCityTourRepository.getSavedTours();
        expect(tours.any((tour) => tour.city == 'Saved City'), true);

        final state = bloc.state;
        expect(state.ecoCityTour?.city, 'Saved City');
      },
    );
  });
}
