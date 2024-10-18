import 'package:flutter/material.dart';
import 'package:project_app/delegates/delegates.dart';

import '../models/models.dart';


class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsetsDirectional.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        width: double.infinity,
        child: GestureDetector(
          onTap: () async {
            // Abrir el SearchDelegate y manejar el resultado
            final result = await showSearch<PointOfInterest?>(
              context: context,
              delegate: SearchDestinationDelegate(),
            );

            // No necesitamos hacer nada más aquí ya que el resultado se maneja en el SearchDelegate
            if (result == null) return;

          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Text(
              '¿Quieres añadir algún lugar?',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}
