import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_app/blocs/blocs.dart';

import 'package:project_app/screens/screens.dart';
import 'package:project_app/services/services.dart';

void main() async {
  //TODO resolver caso de no tener internet para que no se quede buscando...
  //TODO añadir dialog para cuando el usuario escoge un lugar de la lista
  Bloc.observer = MyBlocObserver();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    if (kDebugMode) {
      print("Error específico: $e");
    }
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
                  context))), // Gestión de controlador de mapa.
      BlocProvider(
          create: (context) => SearchBloc(
              // Instancia un trafficService que necesita para rutas.
              trafficService:
                  TrafficService())), // Indica si se quiere hacer una busqueda manual o no.
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
