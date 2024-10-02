import 'package:flutter/material.dart';

// Iconos para el modo de transporte
final Map<String, IconData> transportIcons = {
  'walking': Icons.directions_walk,
  'cycling': Icons.directions_bike,
};

// Iconos y colores para las preferencias del usuario
final Map<String, Map<String, dynamic>> userPreferences = {
  'Naturaleza': {
    'icon': Icons.park,
    'color': Colors.lightBlue,
  },
  'Museos': {
    'icon': Icons.museum,
    'color': Colors.purple,
  },
  'Gastronomía': {
    'icon': Icons.restaurant,
    'color': Colors.green,
  },
  'Deportes': {
    'icon': Icons.sports_soccer,
    'color': Colors.red,
  },
  'Compras': {
    'icon': Icons.shopping_bag,
    'color': Colors.teal,
  },
  'Historia': {
    'icon': Icons.history_edu,
    'color': Colors.orange,
  },
};
