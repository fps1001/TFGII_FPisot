import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/router/app_router.dart';
import 'package:project_app/services/services.dart';
import 'package:project_app/themes/themes.dart';
import 'package:project_app/logger/logger.dart';

void main() async {
  Bloc.observer = MyBlocObserver();
  try {
    await dotenv.load(fileName: '.env');
    log.i('Variables de entorno cargadas');
  } catch (e) {
    log.e("Error en archivo .env: $e");
  }

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
                  context))), // Gestión de controlador de mapa.// Indica si se quiere hacer una busqueda manual o no.
      BlocProvider(
          create: (context) => TourBloc(
              optimizationService: OptimizationService(),
              mapBloc: BlocProvider.of<MapBloc>(
                  context))), // Guarda la información del Tour y sus POIs
    ],
    child: const ProjectApp(),
  ));
}

class ProjectApp extends StatelessWidget {
  const ProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Eco-City Tour',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router);
  }
}
