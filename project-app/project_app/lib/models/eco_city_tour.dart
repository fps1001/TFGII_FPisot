import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'models.dart';

class EcoCityTour {
  final String city;
  final List<PointOfInterest> pois;
  final String mode;
  final List<String> userPreferences;
  final double? duration;  // Hacemos duración opcional
  final double? distance;  // Hacemos distancia opcional
  final List<LatLng> polilynePoints;

  EcoCityTour({
    this.duration,  
    this.distance,  
    required this.polilynePoints,
    required this.city,
    required this.pois,
    required this.mode,
    required this.userPreferences,
  });

  // Getter para el mensaje del logger.
  String get name => city;

  EcoCityTour copyWith({
    String? city,
    List<PointOfInterest>? pois,
    String? mode,
    List<String>? userPreferences,
    double? duration,
    double? distance,
    List<LatLng>? polilynePoints,
  }) {
    return EcoCityTour(
      city: city ?? this.city,
      pois: pois ?? this.pois,
      mode: mode ?? this.mode,
      userPreferences: userPreferences ?? this.userPreferences,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      polilynePoints: polilynePoints ?? this.polilynePoints,
    );
  }
}
