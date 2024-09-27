import 'package:flutter/material.dart';

class LoadingMessageHelper {
  static void showLoadingMessage(BuildContext context) {
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
                  Text('Encontrando lugares de interés'),
                  SizedBox(
                    height: 5,
                  ),
                  CircularProgressIndicator(strokeWidth: 3, color: Colors.black)
                ],
              ),
            )));
    return;
  }
}
// Muestra un mensaje de carga.


