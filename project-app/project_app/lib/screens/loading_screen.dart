import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Importamos GoRouter para la navegación

import 'package:project_app/blocs/blocs.dart';

/// Pantalla de carga inicial.
///
/// Esta pantalla valida si el GPS y los permisos necesarios están habilitados
/// antes de redirigir al usuario a la siguiente pantalla apropiada.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GpsBloc, GpsState>(
      listener: (context, state) {
        if (state.isGpsEnabled && state.isGpsPermissionGranted) {
          context.go('/tour-selection');
        } else {
          context.go('/gps-access');
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
