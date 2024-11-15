import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/screens/screens.dart';

// Mock de GpsBloc
class MockGpsBloc extends Mock implements GpsBloc {}

void main() {
  late MockGpsBloc mockGpsBloc;

  setUp(() {
    mockGpsBloc = MockGpsBloc();
  });


  group('LoadingScreen navigation tests', () {
    testWidgets(
      'Navega a /gps-access cuando el GPS no está listo',
      (WidgetTester tester) async {
        when(() => mockGpsBloc.state).thenReturn(
          const GpsState(isGpsEnabled: false, isGpsPermissionGranted: false),
        );

        final goRouter = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const LoadingScreen(),
            ),
            GoRoute(
              path: '/gps-access',
              builder: (context, state) => const GpsAccessScreen(),
            ),
            GoRoute(
              path: '/tour-selection',
              builder: (context, state) => const Scaffold(body: Text('Tour Selection')),
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerDelegate: goRouter.routerDelegate,
            routeInformationParser: goRouter.routeInformationParser,
          ),
        );

        // Simula el evento para verificar que redirige a /gps-access
        await tester.pumpAndSettle();

        expect(find.text('Debe habilitar el GPS para continuar'), findsOneWidget);
      },
    );

    testWidgets(
      'Navega a /tour-selection cuando el GPS y los permisos están listos',
      (WidgetTester tester) async {
        when(() => mockGpsBloc.state).thenReturn(
          const GpsState(isGpsEnabled: true, isGpsPermissionGranted: true),
        );

        final goRouter = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const LoadingScreen(),
            ),
            GoRoute(
              path: '/gps-access',
              builder: (context, state) => const GpsAccessScreen(),
            ),
            GoRoute(
              path: '/tour-selection',
              builder: (context, state) => const Scaffold(body: Text('Tour Selection')),
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerDelegate: goRouter.routerDelegate,
            routeInformationParser: goRouter.routeInformationParser,
          ),
        );

        // Simula el evento para verificar que redirige a /tour-selection
        await tester.pumpAndSettle();

        expect(find.text('Tour Selection'), findsOneWidget);
      },
    );
  });
}
