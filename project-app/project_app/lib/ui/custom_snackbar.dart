import 'package:flutter/material.dart';

class CustomSnackbar extends SnackBar{
  
  

  CustomSnackbar({
    Key? key,
    required String msg,
    String btn_label = 'Aceptar',
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onPressed
    }) : super(
      key: key,
      content: Text(msg),
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        label: btn_label,
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
        duration: Duration(seconds: 2),
      ),
    );
  }
}