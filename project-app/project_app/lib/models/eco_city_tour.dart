// Clase: EcoCityTour
// Objetivo: Definir la clase EcoCityTour que representa un recorrido ecológico por una ciudad para cargarlo mediante este modelo al sistema.
import 'models.dart';

class EcoCityTour {
  final String city;
  final int numberOfSites;
  final List<PointOfInterest> pois;
  final String mode;

  EcoCityTour({
    required this.city,
    required this.numberOfSites,
    required this.pois,
    required this.mode,
  });
}
