// FILE: widgets/time_slider.dart
import 'package:flutter/material.dart';

class TimeSlider extends StatelessWidget {
  final double maxTimeInMinutes;
  final ValueChanged<double> onChanged;
  final String Function(double) formatTime;

  const TimeSlider({
    super.key,
    required this.maxTimeInMinutes,
    required this.onChanged,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(
          'Tiempo máximo invertido en el trayecto:',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text('15m', style: Theme.of(context).textTheme.headlineSmall),
            Expanded(
              child: Slider(
                value: maxTimeInMinutes,
                min: 15,
                max: 180, // Máximo 3 horas
                divisions: 11, // Cada paso representa 15 minutos
                label: formatTime(maxTimeInMinutes).toString(),
                onChanged: onChanged,
                activeColor: Theme.of(context).primaryColor,
                inactiveColor: Theme.of(context).primaryColor.withOpacity(0.8),
              ),
            ),
            Text('3h', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ],
    );
  }
}
