import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/screens/screens.dart';

class MockTourBloc extends MockBloc<TourEvent, TourState> implements TourBloc {}

class MockGpsBloc extends MockBloc<GpsEvent, GpsState> implements GpsBloc {}

void main() {
  late MockTourBloc mockTourBloc;
  late MockGpsBloc mockGpsBloc;

  late GoRouter goRouter;

  setUpAll(() {
    EasyLocalization.logger.enableLevels = [];
    registerFallbackValue(const LoadTourEvent(
      mode: 'walking',
      city: '',
      numberOfSites: 2,
      userPreferences: [],
      maxTime: 90,
      systemInstruction: '',
    ));
    registerFallbackValue(const LoadSavedToursEvent());
    registerFallbackValue(const OnGpsAndPermissionEvent(
      isGpsEnabled: true,
      isGpsPermissionGranted: true,
    ));
  });

  setUp(() {
    mockTourBloc = MockTourBloc();
    mockGpsBloc = MockGpsBloc();

    goRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<TourBloc>.value(value: mockTourBloc),
              BlocProvider<GpsBloc>.value(value: mockGpsBloc),
            ],
            child: const TourSelectionScreen(),
          ),
        ),
        GoRoute(
          path: '/gps-access',
          builder: (context, state) => const GpsAccessScreen(),
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
    mockGpsBloc.close();
  });

  Widget createTestWidget() {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: MaterialApp.router(
        routerConfig: goRouter,
      ),
    );
  }

  group('TourSelectionScreen Tests', () {
    testWidgets('Renderiza correctamente todos los widgets principales',
        (WidgetTester tester) async {
      when(() => mockGpsBloc.state).thenReturn(
        const GpsState(isGpsEnabled: true, isGpsPermissionGranted: true),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); // Asegura que todo se renderice

      expect(find.text('place_to_visit'.tr()), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('your_interests'.tr()), findsOneWidget);
      expect(find.text('eco_city_tour'.tr()), findsOneWidget);
      expect(find.text('load_saved_route'.tr()), findsOneWidget);
    });

    testWidgets('Dispara LoadTourEvent al pulsar el botón "eco_city_tour"',
        (WidgetTester tester) async {
      when(() => mockGpsBloc.state).thenReturn(
        const GpsState(isGpsEnabled: true, isGpsPermissionGranted: true),
      );
      when(() => mockTourBloc.state).thenReturn(const TourState());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final requestButton = find.text('eco_city_tour'.tr());
      expect(requestButton, findsOneWidget);

      await tester.ensureVisible(requestButton); // Asegura visibilidad
      await tester.tap(requestButton);
      await tester.pump();

      verify(() => mockTourBloc.add(any(that: isA<LoadTourEvent>()))).called(1);
    });

    testWidgets('Navega a SavedToursScreen al pulsar "load_saved_route"',
        (WidgetTester tester) async {
      when(() => mockGpsBloc.state).thenReturn(
        const GpsState(isGpsEnabled: true, isGpsPermissionGranted: true),
      );
      when(() => mockTourBloc.state).thenReturn(const TourState());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final loadSavedToursButton = find.text('load_saved_route'.tr());
      expect(loadSavedToursButton, findsOneWidget);

      await tester.ensureVisible(loadSavedToursButton);
      await tester.tap(loadSavedToursButton);
      await tester.pumpAndSettle();

      verify(() => mockTourBloc.add(any(that: isA<LoadSavedToursEvent>())))
          .called(1);

      expect(find.byType(SavedToursScreen), findsOneWidget);
    });
  });
}
