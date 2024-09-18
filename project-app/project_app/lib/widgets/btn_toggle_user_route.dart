import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/blocs/blocs.dart';

class BtnToggleUserRoute extends StatelessWidget {
  const BtnToggleUserRoute({super.key});

  @override
  Widget build(BuildContext context) {
    // En mapBloc se encuentra el estado del mapa con la última ubicación del usuario.
    final mapBloc = BlocProvider.of<MapBloc>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      // Botón de centrado en la ubicación actual
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor, // Verde
        maxRadius: 25,
        // BlocBuilder para saber si se sigue al usuario.
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            return IconButton(
                icon: Icon(
                    state.showUserRoute
                        ? Icons.mode_rounded
                        : Icons.draw_rounded,
                    color: Colors.white, // Icono blanco),
                ),
                onPressed: () {
                  mapBloc.add(OnToggleShowUserRouteEvent());
                });
          },
        ),
      ),
    );
  }
}
