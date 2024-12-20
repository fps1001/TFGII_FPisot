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
      maxTime: 90,
      systemInstruction: '',
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
      // Simula el estado inicial del Bloc
      when(() => mockTourBloc.state).thenReturn(const TourState());

      // Construye el widget de prueba
      await tester.pumpWidget(createTestWidget());

      // Encuentra el botón "Cargar Ruta Guardada" usando su texto
      final loadSavedToursButton = find.text('CARGAR RUTA GUARDADA');
      expect(loadSavedToursButton, findsOneWidget);

      // Asegúrate de que el botón sea visible desplazando hacia abajo si es necesario
      await tester.ensureVisible(loadSavedToursButton);

      // Simula el tap en el botón
      await tester.tap(loadSavedToursButton);

      // Espera a que se complete cualquier animación o navegación
      await tester.pumpAndSettle();

      // Verifica que el evento LoadSavedToursEvent fue agregado al Bloc
      verify(() => mockTourBloc.add(any(that: isA<LoadSavedToursEvent>())))
          .called(1);

      // Verifica que se navega a 'saved-tours'
      expect(find.byType(SavedToursScreen), findsOneWidget);
    });
  });
}
