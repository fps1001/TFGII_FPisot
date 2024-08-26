import 'package:flutter/material.dart';

// Muestra un mensaje de carga.
void showLoadingMessage(BuildContext context) {
  // Android
  showDialog(
      context: context,
      barrierDismissible: false, // Para que lo pueda quitar el usuario.
      builder: (context) => const AlertDialog(
          title: Text('Espere por favor'), content: Text('Calculando ruta')));
  return;
}
