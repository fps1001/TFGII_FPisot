// lib/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/screens/screens.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/tour-selection',
        name: 'tour-selection',
        builder: (context, state) => const TourSelectionScreen(),
      ),
      GoRoute(
        path: '/gps-access',
        name: 'gps-access',
        builder: (context, state) => const GpsAccessScreen(),
      ),
      GoRoute(
        path: '/tour-summary',
        name: 'tour-summary',
        builder: (context, state) => const TourSummary(),
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) {
          final ecoCityTour = state.extra as EcoCityTour;
          return MapScreen(tour: ecoCityTour);
        },
      ),
    ],
  );
}

