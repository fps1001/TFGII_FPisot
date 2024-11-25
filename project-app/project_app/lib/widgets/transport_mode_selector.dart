// FILE: widgets/transport_mode_selector.dart
import 'package:flutter/material.dart';
import 'package:project_app/helpers/icon_helpers.dart'; // Importar icon_helpers.dart

class TransportModeSelector extends StatelessWidget {
  final List<bool> isSelected;
  final ValueChanged<int> onPressed;

  const TransportModeSelector({
    super.key,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Selecciona tu modo de transporte',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Center(
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(25.0),
            isSelected: isSelected,
            onPressed: onPressed,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(transportIcons['walking']),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(transportIcons['cycling']),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
