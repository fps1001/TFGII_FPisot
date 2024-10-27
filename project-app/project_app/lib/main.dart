import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'firebase_options.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/router/app_router.dart';
import 'package:project_app/services/services.dart';
import 'package:project_app/themes/themes.dart';
import 'package:project_app/logger/logger.dart';

void main() async {
  // Asegurarse de que Flutter se haya inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase según indica la consola.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configurar Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  Bloc.observer = MyBlocObserver();

  try {
    await dotenv.load(fileName: '.env');
    log.i('Variables de entorno cargadas');
  } catch (e) {
    log.e("Error en archivo .env: $e");
    // También registrar el error en Crashlytics
    FirebaseCrashlytics.instance.recordError(e, null);
  }

  // Ejecutar la aplicación con MultiBlocProvider
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => GpsBloc()), // Gestión de permiso de localización y GPS activo.
      BlocProvider(create: (context) => LocationBloc()), // Gestión de localización de usuario.
      BlocProvider(
        create: (context) => MapBloc(
          locationBloc: BlocProvider.of<LocationBloc>(context),
        ),
      ), // Gestión del controlador de mapa.
      BlocProvider(
        create: (context) => TourBloc(
          optimizationService: OptimizationService(),
          mapBloc: BlocProvider.of<MapBloc>(context),
        ),
      ), // Información del Tour y sus POIs
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
      routerConfig: AppRouter.router,
    );
  }
}
