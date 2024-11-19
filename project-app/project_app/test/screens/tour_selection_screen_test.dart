import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/screens/screens.dart';

class MockTourBloc extends MockBloc<TourEvent, TourState> implements TourBloc {}

void main() {
  late MockTourBloc mockTourBloc;

  // Configuración de GoRouter para los tests
  late GoRouter goRouter;

  setUpAll(() {
    registerFallbackValue(const LoadTourEvent(
      mode: 'walking',
      city: '',
      numberOfSites: 2,
      userPreferences: [],
      maxTime: 90, systemInstruction: '',
    ));
    registerFallbackValue(const LoadSavedToursEvent());
  });

  setUp(() {
    // Inicializar el mock del Bloc
    mockTourBloc = MockTourBloc();

    // Configuración de GoRouter con `BlocProvider` a nivel raíz
    goRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<TourBloc>.value(
            value: mockTourBloc,
            child: const TourSelectionScreen(),
          ),
        ),
        GoRoute(
          path: '/saved-tours',
          name: 'saved-tours',
          builder: (context, state) => BlocProvider<TourBloc>.value(
            value: mockTourBloc,
            child: const SavedToursScreen(),
          ),
        ),
      ],
    );
  });

  tearDown(() {
    mockTourBloc.close();
  });

  Widget createTestWidget() {
    return MaterialApp.router(
      routerConfig: goRouter,
    );
  }

  group('TourSelectionScreen Tests', () {
    testWidgets('Renderiza correctamente todos los widgets principales',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('¿Qué lugar quieres visitar?'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('¿Cuántos sitios te gustaría visitar?'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(2));
      expect(find.text('Selecciona tu modo de transporte'), findsOneWidget);
      expect(find.byType(ToggleButtons), findsOneWidget);
      expect(find.text('¿Cuáles son tus intereses?'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(6));
      expect(find.text('REALIZAR ECO-CITY TOUR'), findsOneWidget);
    });

    testWidgets(
        'Dispara LoadTourEvent al pulsar el botón "REALIZAR ECO-CITY TOUR"',
        (WidgetTester tester) async {
      when(() => mockTourBloc.state).thenReturn(const TourState());

      await tester.pumpWidget(createTestWidget());
      final requestButton = find.text('REALIZAR ECO-CITY TOUR');
      expect(requestButton, findsOneWidget);

      await tester.ensureVisible(requestButton);
      await tester.tap(requestButton);
      await tester.pump();

      verify(() => mockTourBloc.add(any(that: isA<LoadTourEvent>()))).called(1);
    });

    testWidgets('Navega a SavedToursScreen al pulsar "Cargar Ruta Guardada"',
        (WidgetTester tester) async {
      when(() => mockTourBloc.state).thenReturn(const TourState());

      await tester.pumpWidget(createTestWidget());
      final loadSavedToursButton = find.byTooltip('Cargar Ruta Guardada');
      expect(loadSavedToursButton, findsOneWidget);

      await tester.tap(loadSavedToursButton);
      await tester.pumpAndSettle();

      verify(() => mockTourBloc.add(any(that: isA<LoadSavedToursEvent>()))).called(1);
    });



testWidgets('Actualiza la preferencia seleccionada correctamente', 
    (WidgetTester tester) async {
  await tester.pumpWidget(createTestWidget());

  // Busca el `ChoiceChip` por su texto
  final natureChip = find.widgetWithText(ChoiceChip, 'Naturaleza');
  expect(natureChip, findsOneWidget);

  // Verifica que el chip no está seleccionado inicialmente
  final natureChipWidgetBefore = tester.widget<ChoiceChip>(natureChip);
  expect(natureChipWidgetBefore.selected, isFalse);

  // Simula un tap en el chip
  await tester.tap(natureChip);
  await tester.pumpAndSettle();

  // Verifica que el chip ahora está seleccionado
  final natureChipWidgetAfter = tester.widget<ChoiceChip>(natureChip);
  expect(natureChipWidgetAfter.selected, isTrue);
});

  });
}
