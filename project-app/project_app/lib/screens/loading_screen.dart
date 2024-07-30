import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/screens/screens.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GpsBloc, GpsState>(
        builder: (context, state) {
          return state.isAllReady // Si el GPS y los permisos están listos, se muestra el mapa, si no, se muestra la pantalla de acceso al GPS
              ? const MapScreen()
              : const GpsAccessScreen();
        },
      ),
    );
  }
}