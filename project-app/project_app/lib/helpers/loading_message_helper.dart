import 'package:flutter/material.dart';

class LoadingMessageHelper {
  static void showLoadingMessage(BuildContext context) {
    // Android
    showDialog(
        context: context,
        barrierDismissible: false, // Para que lo pueda quitar el usuario.
        builder: (context) => AlertDialog(
            title: Text('Espere por favor',
                style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                )),
            content: Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Text(
                    'Encontrando lugares de interés',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Theme.of(context).primaryColor,
                  )
                ],
              ),
            )));
    return;
  }
}
// Muestra un mensaje de carga.


