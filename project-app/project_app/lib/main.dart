import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Agregado para la autenticación

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/datasets/datasets.dart';
import 'package:project_app/firebase_options.dart';
import 'package:project_app/repositories/repositories.dart';
import 'package:project_app/router/app_router.dart';
import 'package:project_app/services/services.dart';
import 'package:project_app/themes/themes.dart';
import 'package:project_app/logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicializar Firebase usando las variables de entorno
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Autenticar al usuario de forma anónima
  final User? user = await _authenticateUser();

  Bloc.observer = MyBlocObserver();

  // Instancia de FirestoreDataset y EcoCityTourRepository, pasando userId
  final firestoreDataset = FirestoreDataset(userId: user?.uid);
  final ecoCityTourRepository = EcoCityTourRepository(firestoreDataset);

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => GpsBloc()),
      BlocProvider(create: (context) => LocationBloc()),
      BlocProvider(
          create: (context) =>
              MapBloc(locationBloc: BlocProvider.of<LocationBloc>(context))),
      BlocProvider(
          create: (context) => TourBloc(
              optimizationService: OptimizationService(),
              mapBloc: BlocProvider.of<MapBloc>(context),
              ecoCityTourRepository: ecoCityTourRepository)),
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

// Función para autenticar al usuario de forma anónima
Future<User?> _authenticateUser() async {
  try {
    final auth = FirebaseAuth.instance;
    // Si ya hay un usuario autenticado, retorna ese usuario
    if (auth.currentUser != null) {
      return auth.currentUser;
    }
    // Si no hay usuario autenticado, realiza la autenticación anónima
    final userCredential = await auth.signInAnonymously();
    log.i("Usuario autenticado de forma anónima: ${userCredential.user?.uid}");
    return userCredential.user;
  } catch (e) {
    log.e("Error en autenticación anónima: $e");
    return null;
  }
}
