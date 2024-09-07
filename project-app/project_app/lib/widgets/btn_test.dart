import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BtnTest extends StatelessWidget {
  const BtnTest({super.key});

  @override
  Widget build(BuildContext context) {
    // Coordenadas de prueba para Salamanca, España (centro)
    final List<LatLng> salamancaCoordinates = [
      LatLng(40.964165, -5.663774), // Plaza Mayor
      LatLng(40.962903, -5.666918), // Catedral de Salamanca
      LatLng(40.965479, -5.668760), // Casa de las Conchas
      LatLng(40.963776, -5.669952), // Universidad de Salamanca
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      // Botón de centrado en la ubicación actual
      child: CircleAvatar(
        backgroundColor: Colors.white,
        maxRadius: 25,
        // BlocBuilder para saber si se sigue al usuario.
        child: IconButton(
            icon: Icon(Icons.quiz_rounded, color: Colors.black),
            onPressed: () {
              
            }),
      ),
    );
  }
}
