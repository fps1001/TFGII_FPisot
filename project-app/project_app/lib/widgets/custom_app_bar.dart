import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart'; // Importar GoRouter

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TourState tourState; // Recibe el estado del Tour

  const CustomAppBar({
    super.key,
    required this.title,
    required this.tourState,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: Theme.of(context).appBarTheme.elevation,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.refresh), // Icono de reinicio
        onPressed: () {
          log.i('MapScreen: Regresando a la selección de EcoCityTour.');
          // Reiniciar el estado del tour antes de volver
          BlocProvider.of<TourBloc>(context).add(const ResetTourEvent());
          // Navegar directamente a la pantalla de selección de tours
          context.go('/tour-selection');
        },
      ),
      actions: [
        if (tourState.ecoCityTour != null)
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              log.i('MapScreen: Abriendo resumen del EcoCityTour');
              context.push('/tour-summary');
            },
          )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
