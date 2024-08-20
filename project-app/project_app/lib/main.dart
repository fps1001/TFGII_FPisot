import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/blocs/blocs.dart';

import 'package:project_app/screens/screens.dart';

void main() {
  runApp(MultiBlocProvider(
    // En vez de hacer runApp se añade un multiblocprovider para gestionar los blocs de la app.
    providers: [
      BlocProvider(
          create: (context) =>
              GpsBloc()), // Gestión de permiso de localización y GPS activo.
      BlocProvider(
          create: (context) =>
              LocationBloc()), // Gestión de localización de usuario.
      BlocProvider(
          create: (context) => MapBloc(
              locationBloc: BlocProvider.of<LocationBloc>(
                  context))), // Gestión de controlador de mapa.
      BlocProvider(
          create: (context) =>
              SearchBloc()), // Indica si se quiere hacer una busqueda manual o no.
    ],
    child: const ProjectApp(),
  ));
}

class ProjectApp extends StatelessWidget {
  const ProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Eco-City Tour',
        home: LoadingScreen());
  }
}
