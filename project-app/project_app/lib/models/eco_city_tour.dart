// Clase: EcoCityTour

import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'models.dart';

class EcoCityTour {
  final String city;
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
    required this.pois,
    required this.mode,
    required this.userPreferences,
  });

  // Para mensaje de logger me hace falta un getter.
  String get name => city;

  EcoCityTour copyWith({
    String? city,
    int? numberOfSites,
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
