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
            backgroundColor: Colors.white,
            maxRadius: 25,
            // BlocBuilder para saber si se sigue al usuario.
            child: IconButton(
              icon: const Icon( Icons.more_horiz_rounded,
                  color: Colors.black),
              onPressed: () {
                mapBloc.add(OnToggleShowUserRouteEvent());
              }  
            )
        )
    );
                    
  }
}