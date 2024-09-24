import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF00A86B); // Verde principal (del ícono)
  static const secundary = Color(0xFF0047AB); // Azul secundario (del ícono)

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secundary,
        surface: Colors.white, // Fondo blanco
      ),
      scaffoldBackgroundColor: Colors.grey[200], // Fondo del Scaffold

      // Estilos de texto
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        headlineMedium: TextStyle(fontSize: 16, color: Colors.black87),
        headlineSmall: TextStyle(fontSize: 14, color: Colors.black54),
      ),

      // Estilos de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, // Fondo verde del botón
          foregroundColor: Colors.white, // Texto en blanco
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Estilo del AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primary, // Azul para el AppBar
        elevation: 4, // Elevación/sombra
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Tema oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.blueGrey, // Azul oscuro
        secondary: Colors.blue, // Color de acento
        surface: Colors.black, // Fondo negro
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey, // Fondo del botón
          foregroundColor: Colors.white, // Texto en blanco
        ),
      ),
    );
  }
}
