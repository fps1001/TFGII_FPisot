import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Importamos GoRouter para la navegación

import 'package:project_app/blocs/blocs.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GpsBloc, GpsState>(
      listener: (context, state) {
        if (state.isAllReady) {
          // Si el GPS y los permisos están listos, redirige a la pantalla de selección de tours
          context.go('/tour-selection'); // Navega a la ruta de selección de tours
        } else {
          // Si no está listo, redirige a la pantalla de acceso al GPS
          context.go('/gps-access'); // Navega a la ruta de acceso al GPS
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Mostrar indicador de carga mientras espera la validación
        ),
      ),
    );
  }
}
