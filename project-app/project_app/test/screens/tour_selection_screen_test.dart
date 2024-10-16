import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/screens/screens.dart';

// Fake de TourEvent para registrar fallback en mocktail
class FakeTourEvent extends Fake implements TourEvent {}

// Mock de TourBloc
class MockTourBloc extends Mock implements TourBloc {}

void main() {
  setUpAll(() {
    // Registrar un fallback para TourEvent
    registerFallbackValue(FakeTourEvent());
  });

  testWidgets(
      "Verifica que al presionar el botón se añade un evento LoadTourEvent",
      (WidgetTester tester) async {
    // Configurar el mock del TourBloc
    final mockTourBloc = MockTourBloc();

    when(() => mockTourBloc.add(any())).thenReturn(null);

    // Ajustar el tamaño de la pantalla para asegurarse de que el botón sea visible
    await tester.binding.setSurfaceSize(const Size(1080, 1920));

    // Renderizar el widget TourSelectionScreen
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TourBloc>(
          create: (_) => mockTourBloc,
          child: const TourSelectionScreen(),
        ),
      ),
    );

    // Verificar que el texto del botón está presente en la pantalla
    expect(find.text('REALIZAR ECO-CITY TOUR'), findsOneWidget);

    // Simular el tap en el botón
    await tester.tap(find.text('REALIZAR ECO-CITY TOUR'));
    await tester.pumpAndSettle(); // Esperar a que se actualice la interfaz

    // Verificar que se añade el evento LoadTourEvent
    verify(() => mockTourBloc.add(any<LoadTourEvent>())).called(1);
  });
}
