import 'package:flutter/material.dart';

// Muestra un mensaje de carga.
void showLoadingMessage(BuildContext context) {
  // Android
  showDialog(
      context: context,
      barrierDismissible: false, // Para que lo pueda quitar el usuario.
      builder: (context) => AlertDialog(
          title: const Text('Espere por favor'),
          content: Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.only(top: 10),
            child: const Column(
              children: [
                Text('Calculando ruta'),
                SizedBox(
                  height: 5,
                ),
                CircularProgressIndicator(strokeWidth: 3, color: Colors.black)
              ],
            ),
          )));
  return;
}
