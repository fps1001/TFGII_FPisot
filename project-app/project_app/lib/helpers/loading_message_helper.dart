import 'package:flutter/material.dart';

class LoadingMessageHelper {
  static void showLoadingMessage(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible:
            false, // Evita que el usuario lo cierre accidentalmente.
        builder: (context) => AlertDialog(
            title: Text(
              'Espere por favor',
              textAlign: TextAlign.center, // Centrar el título
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            content: IntrinsicHeight(
              // Dejar que el contenido se ajuste a su tamaño natural
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Adaptar la altura según el contenido
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centrar el contenido verticalmente
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Centrar horizontalmente
                children: [
                  Text(
                    'Trabajando en tu\nEco City Tour',
                    textAlign: TextAlign.center, // Centrar el texto
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(
                    height: 20, // Espacio entre el texto y el indicador
                  ),
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            )));
  }
}
