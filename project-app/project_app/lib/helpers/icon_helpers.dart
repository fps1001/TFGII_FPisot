import 'package:flutter/material.dart';

/// Iconos para los diferentes modos de transporte disponibles.
///
/// El mapa asocia el nombre del modo de transporte con un icono de Material Design.
final Map<String, IconData> transportIcons = {
  'walking': Icons.directions_walk, // Icono para caminar
  'cycling': Icons.directions_bike, // Icono para ciclismo
};

/// Configuración de iconos y colores para las preferencias del usuario.
///
/// Cada preferencia está asociada con:
/// - Un icono representativo de Material Design.
/// - Un color que se utiliza para personalizar la interfaz según la preferencia.
final Map<String, Map<String, dynamic>> userPreferences = {
  'Naturaleza': {
    'icon': Icons.park, // Icono representativo de naturaleza
    'color': Colors.lightBlue, // Color asociado
  },
  'Museos': {
    'icon': Icons.museum, // Icono representativo de museos
    'color': Colors.purple, // Color asociado
  },
  'Gastronomía': {
    'icon': Icons.restaurant, // Icono representativo de gastronomía
    'color': Colors.green, // Color asociado
  },
  'Deportes': {
    'icon': Icons.sports_soccer, // Icono representativo de deportes
    'color': Colors.red, // Color asociado
  },
  'Compras': {
    'icon': Icons.shopping_bag, // Icono representativo de compras
    'color': Colors.teal, // Color asociado
  },
  'Historia': {
    'icon': Icons.history_edu, // Icono representativo de historia
    'color': Colors.orange, // Color asociado
  },
};
