// Clase: EcoCityTour
// Objetivo: Definir la clase EcoCityTour que representa un recorrido ecológico por una ciudad para cargarlo mediante este modelo al sistema.
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'models.dart';

class EcoCityTour {
  final String city;
  final int numberOfSites; //longitud de pois, en teoría no haría falta
  final List<PointOfInterest> pois;
  final String mode;
  final List<String> userPreferences;
  final double duration;
  final double distance;
  final List<LatLng> polilynePoints;

  
  EcoCityTour({
    required this.duration,
    required this.distance, 
    required this.polilynePoints, 

    required this.city,
    required this.numberOfSites,
    required this.pois,
    required this.mode,
    required this.userPreferences,});
  
}
