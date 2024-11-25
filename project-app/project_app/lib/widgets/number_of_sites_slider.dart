// FILE: widgets/number_of_sites_slider.dart
import 'package:flutter/material.dart';

class NumberOfSitesSlider extends StatelessWidget {
  final double numberOfSites;
  final ValueChanged<double> onChanged;

  const NumberOfSitesSlider({
    super.key,
    required this.numberOfSites,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          '¿Cuántos sitios te gustaría visitar?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('2', style: Theme.of(context).textTheme.headlineSmall),
            Expanded(
              child: Slider(
                value: numberOfSites,
                min: 2,
                max: 8,
                divisions: 6, // Cada paso representa un sitio
                label: numberOfSites.round().toString(),
                onChanged: onChanged,
                activeColor: Theme.of(context).primaryColor,
                inactiveColor: Theme.of(context).primaryColor.withOpacity(0.8),
              ),
            ),
            Text('8', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ],
    );
  }
}
