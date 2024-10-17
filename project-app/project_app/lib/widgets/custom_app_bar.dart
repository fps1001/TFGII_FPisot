import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TourState tourState;

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
      iconTheme: const IconThemeData(color: Colors.white), // Iconos en blanco
      leading: IconButton(
        icon: const Icon(Icons.arrow_back), // Icono de retroceso
        onPressed: () async {
          // Si ecoCityTour es null, no mostramos el diálogo y simplemente navegamos
          if (tourState.ecoCityTour == null) {
            log.i('MapScreen: ecoCityTour es null, navegando sin confirmación.');
            context.push('/tour-selection');
            return;
          }

          // Mostrar diálogo de confirmación antes de regresar
          final shouldReset = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Generar otro Eco City Tour'),
              content: const Text('Se borrará el tour actual. ¿Estás seguro?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Cerrar sin acción
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Confirmar acción
                  child: const Text('Sí'),
                ),
              ],
            ),
          );

          // Verifica si el widget sigue montado antes de usar el contexto
          if (!context.mounted || shouldReset != true) return;

          log.i('MapScreen: Regresando a la selección de EcoCityTour.');
          // Reiniciar el estado del tour antes de volver
          BlocProvider.of<TourBloc>(context).add(const ResetTourEvent());
          // Navegar a la pantalla de selección de tours
          context.push('/tour-selection');
        },
      ),
      actions: [
        if (tourState.ecoCityTour != null)
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              log.i('MapScreen: Abriendo resumen del EcoCityTour');
              context.push('/tour-summary'); // Abrir resumen del tour
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
