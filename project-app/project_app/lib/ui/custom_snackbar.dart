import 'package:flutter/material.dart';

class CustomSnackbar extends SnackBar {
  CustomSnackbar(
      {super.key,
      required String msg,
      String btnLabel = 'Aceptar',
      Duration duration = const Duration(seconds: 2),
      VoidCallback? onPressed})
      : super(
          content: Text(msg),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: btnLabel,
            onPressed: () {
              if (onPressed != null) {
                onPressed();
              }
            },
          ),
        );

  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
