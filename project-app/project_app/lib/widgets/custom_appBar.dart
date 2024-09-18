import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true, // Centramos el título
      title: Text(
        title,
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              color: Colors.white, // Hacer el texto blanco
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Usamos el color de la AppBar desde el Theme
      elevation: Theme.of(context).appBarTheme.elevation, // Elevación del Theme
      iconTheme: const IconThemeData(color: Colors.white), // Hacemos que el icono sea blanco
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
