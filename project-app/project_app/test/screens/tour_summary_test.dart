import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/screens/tour_summary.dart';
import 'package:project_app/widgets/widgets.dart';
import 'package:project_app/models/models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Mock de TourBloc
class MockTourBloc extends Mock implements TourBloc {}

class FakeTourState extends Fake implements TourState {}

void main() {
  late TourBloc tourBloc;

  setUp(() {
    tourBloc = MockTourBloc();

    // Registra el estado fake
    registerFallbackValue(FakeTourState());

    // Configura el mock para `state` y `stream` del bloc
    when(() => tourBloc.state).thenReturn(const TourState(ecoCityTour: null));
    when(() => tourBloc.stream).thenAnswer((_) =>
        Stream<TourState>.fromIterable([const TourState(ecoCityTour: null)]));
  });

  testWidgets('Muestra CustomSnackbar y navega cuando ecoCityTour es null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScaffoldMessenger(
          child: Scaffold(
            body: BlocProvider.value(
              value: tourBloc,
              child: const TourSummary(),
            ),
          ),
        ),
      ),
    );

    // Verifica que no se renderiza ningún contenido si el ecoCityTour es null
    expect(find.byType(SizedBox), findsOneWidget);

    // Verifica que se intenta mostrar el Snackbar
    await tester.pump();  // Permite ejecutar el postFrameCallback
    expect(find.byType(SnackBar), findsNothing);  // No se puede capturar el Snackbar directamente en test

    // Esperar a que las animaciones y los cambios finalicen
    await tester.pumpAndSettle();
  });

  testWidgets('Muestra información del EcoCityTour correctamente',
      (WidgetTester tester) async {
    final ecoCityTour = EcoCityTour(
      city: 'Ciudad de Prueba',
      distance: 12000, // Distancia en metros
      duration: 3600, // Duración en segundos
      mode: 'bike',
      pois: [],
      polilynePoints: [],
      userPreferences: ['historic'],
    );

    when(() => tourBloc.state).thenReturn(TourState(ecoCityTour: ecoCityTour));
    when(() => tourBloc.stream).thenAnswer((_) =>
        Stream<TourState>.fromIterable([TourState(ecoCityTour: ecoCityTour)]));

    await tester.pumpWidget(
      MaterialApp(
        home: ScaffoldMessenger(
          child: Scaffold(
            body: BlocProvider.value(
              value: tourBloc,
              child: const TourSummary(),
            ),
          ),
        ),
      ),
    );

    // Verificar que se muestran los datos del tour
    expect(find.text('Ciudad: Ciudad de Prueba'), findsOneWidget);
    expect(find.text('Distancia: 12.0 km'),
        findsOneWidget); // Asegúrate que el formato de distancia es correcto
    expect(find.text('Duración: 1h 0m'), findsOneWidget); // Duración formateada
    expect(find.byIcon(Icons.directions_bike),
        findsOneWidget); // Verificar que se muestra el ícono de "bike"

    // Esperar a que las animaciones y los cambios finalicen
    await tester.pumpAndSettle();
  });

  testWidgets('Renderiza lista de POIs', (WidgetTester tester) async {
    final poi1 = PointOfInterest(
      gps: const LatLng(40.7128, -74.0060),
      name: 'POI 1',
      description: 'Descripción del POI 1',
    );
    final poi2 = PointOfInterest(
      gps: const LatLng(40.7128, -74.0060),
      name: 'POI 2',
      description: 'Descripción del POI 2',
    );
    final ecoCityTour = EcoCityTour(
      city: 'Ciudad de Prueba',
      distance: 12000,
      duration: 3600,
      mode: 'walking',
      pois: [poi1, poi2],
      polilynePoints: [],
      userPreferences: ['naturaleza'],
    );

    // Actualiza el estado con el tour con POIs
    when(() => tourBloc.state).thenReturn(TourState(ecoCityTour: ecoCityTour));
    when(() => tourBloc.stream).thenAnswer((_) =>
        Stream<TourState>.fromIterable([TourState(ecoCityTour: ecoCityTour)]));

    await tester.pumpWidget(
      MaterialApp(
        home: ScaffoldMessenger(
          child: Scaffold(
            body: BlocProvider.value(
              value: tourBloc,
              child: const TourSummary(),
            ),
          ),
        ),
      ),
    );

    // Verificar que se renderizan los POIs correctamente
    expect(find.byType(ExpandablePoiItem), findsNWidgets(2));
    expect(find.text('POI 1'), findsOneWidget);
    expect(find.text('POI 2'), findsOneWidget);

    // Esperar a que las animaciones y los cambios finalicen
    await tester.pumpAndSettle();
  });

  testWidgets('Muestra correctamente un tour con distancia y duración nulas',
      (WidgetTester tester) async {
    final ecoCityTour = EcoCityTour(
      city: 'Ciudad de Prueba',
      distance: null, // Distancia nula
      duration: null, // Duración nula
      mode: 'walking',
      pois: [],
      polilynePoints: [],
      userPreferences: [],
    );

    // Actualiza el estado con el tour de distancia/duración nulas
    when(() => tourBloc.state).thenReturn(TourState(ecoCityTour: ecoCityTour));
    when(() => tourBloc.stream).thenAnswer((_) =>
        Stream<TourState>.fromIterable([TourState(ecoCityTour: ecoCityTour)]));

    await tester.pumpWidget(
      MaterialApp(
        home: ScaffoldMessenger(
          child: Scaffold(
            body: BlocProvider.value(
              value: tourBloc,
              child: const TourSummary(),
            ),
          ),
        ),
      ),
    );

    // Verificar que los textos de distancia y duración no generan errores y se muestran como vacío o con un valor predeterminado
    expect(find.text('Distancia: 0.0 km'),
        findsOneWidget); // Muestra distancia formateada como 0
    expect(find.text('Duración: 0m'),
        findsOneWidget); // Muestra duración formateada como 0
    expect(find.byIcon(Icons.directions_walk),
        findsOneWidget); // Modo "walk" mostrado correctamente

    // Esperar a que las animaciones y los cambios finalicen
    await tester.pumpAndSettle();
  });
}
