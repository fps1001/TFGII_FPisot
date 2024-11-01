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
          final ecoCityTourJson = state.extra as Map<String, dynamic>;
          final ecoCityTour = EcoCityTour.fromJson(ecoCityTourJson);
          return MapScreen(tour: ecoCityTour);
        },
      ),
      GoRoute(
        path: '/saved-tours',
        name: 'saved-tours',
        builder: (context, state) {
          return const SavedToursScreen();
        },
      ),
    ],
  );
}
