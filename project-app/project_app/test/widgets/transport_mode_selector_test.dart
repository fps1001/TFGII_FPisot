// FILE: test/widgets/transport_mode_selector_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_app/widgets/transport_mode_selector.dart';
import 'package:project_app/helpers/icon_helpers.dart'; // Asegúrate de que esta ruta sea correcta

void main() {
  group('TransportModeSelector Widget Tests', () {
    testWidgets('Displays correct header and icons', (WidgetTester tester) async {
      final List<bool> isSelected = [true, false];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransportModeSelector(
              isSelected: isSelected,
              onPressed: (_) {},
            ),
          ),
        ),
      );

      // Verifica que el encabezado esté presente
      expect(find.text('Selecciona tu modo de transporte'), findsOneWidget);

      // Verifica que los íconos estén presentes
      expect(find.byIcon(transportIcons['walking']!), findsOneWidget);
      expect(find.byIcon(transportIcons['cycling']!), findsOneWidget);
    });

    testWidgets('Toggles transport mode on button press', (WidgetTester tester) async {
      List<bool> isSelected = [true, false];
      int pressedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransportModeSelector(
              isSelected: isSelected,
              onPressed: (index) {
                pressedIndex = index;
                isSelected = List.generate(isSelected.length, (i) => i == index);
              },
            ),
          ),
        ),
      );

      // Encuentra los botones de transporte
      final walkingButtonFinder = find.byIcon(transportIcons['walking']!);
      final cyclingButtonFinder = find.byIcon(transportIcons['cycling']!);

      // Presiona el botón de bicicleta
      await tester.tap(cyclingButtonFinder);
      await tester.pumpAndSettle();

      // Verifica que el índice seleccionado sea el correcto
      expect(pressedIndex, 1);
      expect(isSelected, [false, true]);

      // Presiona el botón de caminar
      await tester.tap(walkingButtonFinder);
      await tester.pumpAndSettle();

      // Verifica que el índice seleccionado sea el correcto
      expect(pressedIndex, 0);
      expect(isSelected, [true, false]);
    });
  });
}