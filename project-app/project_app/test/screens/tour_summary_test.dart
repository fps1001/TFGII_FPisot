import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/blocs/tour/tour_bloc.dart';
import 'package:project_app/models/eco_city_tour.dart';
import 'package:project_app/models/point_of_interest.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/screens/screens.dart';

class MockTourBloc extends Mock implements TourBloc {}

void main() {
  late MockTourBloc mockTourBloc;

  setUp(() {
    mockTourBloc = MockTourBloc();

    // Configura el stream inicial de TourBloc
    whenListen(
      mockTourBloc,
      const Stream<TourState>.empty(),
      initialState: const TourState(ecoCityTour: null),
    );
  });

  group('TourSummary Widget Tests', () {
    testWidgets('Muestra Snackbar y navega hacia atrás cuando ecoCityTour es null',
        (WidgetTester tester) async {
      // Define el estado inicial con ecoCityTour como null
      when(() => mockTourBloc.state).thenReturn(const TourState(ecoCityTour: null));

      // Carga la pantalla en el test
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold( // Envolver con Scaffold
            body: BlocProvider<TourBloc>.value(
              value: mockTourBloc,
              child: const TourSummary(),
            ),
          ),
        ),
      );

      // Verifica que muestra un `SizedBox` vacío
      expect(find.byType(SizedBox), findsOneWidget);

      // Permite que se ejecute el `addPostFrameCallback` para el Snackbar
      await tester.pump();
      expect(find.text('Eco City Tour vacío, genera uno nuevo'), findsOneWidget);
    });

    group('TourSummary Widget Tests', () {
    testWidgets('Muestra los detalles del tour cuando ecoCityTour tiene datos',
        (WidgetTester tester) async {
      // Crea un modelo de `EcoCityTour` de prueba
      final ecoCityTour = EcoCityTour(
        city: 'Ciudad de prueba',
        pois: [
          PointOfInterest(
            gps: const LatLng(0.0, 0.0),
            name: 'POI de prueba',
            description: 'Un punto de interés de prueba',
            url: 'http://example.com',
            imageUrl: 'http://image.com',
            rating: 4.5,
            address: 'Dirección de prueba',
            userRatingsTotal: 100,
          ),
        ],
        mode: 'walking',
        userPreferences: ['nature'],
        duration: 120,
        distance: 5.0,
        polilynePoints: [const LatLng(0.0, 0.0)],
      );

      // Configura el estado con un ecoCityTour lleno
      when(() => mockTourBloc.state).thenReturn(TourState(ecoCityTour: ecoCityTour));
      whenListen(
        mockTourBloc,
        Stream<TourState>.fromIterable([TourState(ecoCityTour: ecoCityTour)]),
      );

      // Carga la pantalla en el test
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<TourBloc>.value(
              value: mockTourBloc,
              child: const TourSummary(),
            ),
          ),
        ),
      );

      // Verifica que muestra la ciudad y otros detalles del tour
      expect(find.text('Ciudad: Ciudad de prueba'), findsOneWidget);

      // Ajusta el test para buscar "Distancia:" y "Duración:" sin valores específicos
      expect(find.textContaining('Distancia:'), findsOneWidget); // Captura cualquier formato de distancia
      expect(find.textContaining('Duración:'), findsOneWidget);  // Captura cualquier formato de duración
      expect(find.byIcon(Icons.directions_walk), findsOneWidget);
      expect(find.text('POI de prueba'), findsOneWidget);
    });
  });


    testWidgets('Muestra cuadro de diálogo al tocar el botón de guardar',
        (WidgetTester tester) async {
      final ecoCityTour = EcoCityTour(
        city: 'Ciudad de prueba',
        pois: [],
        mode: 'walking',
        userPreferences: [],
        duration: 120,
        distance: 5.0,
        polilynePoints: [],
      );

      // Configura el estado con un ecoCityTour lleno
      when(() => mockTourBloc.state).thenReturn(TourState(ecoCityTour: ecoCityTour));
      whenListen(
        mockTourBloc,
        Stream<TourState>.fromIterable([TourState(ecoCityTour: ecoCityTour)]),
      );

      // Carga la pantalla en el test
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<TourBloc>.value(
              value: mockTourBloc,
              child: const TourSummary(),
            ),
          ),
        ),
      );

      // Toca el botón de guardar
      await tester.tap(find.byIcon(Icons.save_as_rounded));
      await tester.pumpAndSettle();

      // Verifica que aparece el cuadro de diálogo para el nombre del tour
      expect(find.text('Nombre del Tour'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
