import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/models/point_of_interest.dart';

class EcoCityTour {
  final String city;
  final List<PointOfInterest> pois;
  final String mode;
  final List<String> userPreferences;
  final double? duration;
  final double? distance;
  final List<LatLng> polilynePoints;
  final String? documentId;

  EcoCityTour({
    this.duration,
    this.distance,
    required this.polilynePoints,
    required this.city,
    required this.pois,
    required this.mode,
    required this.userPreferences,
    this.documentId,
  });

  // Método para convertir EcoCityTour a JSON
  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'pois': pois.map((poi) => poi.toJson()).toList(),
      'mode': mode,
      'userPreferences': userPreferences,
      'duration': duration,
      'distance': distance,
      'polilynePoints': polilynePoints.map((point) => {'latitude': point.latitude, 'longitude': point.longitude}).toList(),
      'documentId': documentId,
    };
  }

  // Método para crear una instancia de EcoCityTour desde JSON
  factory EcoCityTour.fromJson(Map<String, dynamic> json) {
    return EcoCityTour(
      city: json['city'],
      pois: (json['pois'] as List).map((poi) => PointOfInterest.fromJson(poi)).toList(),
      mode: json['mode'],
      userPreferences: List<String>.from(json['userPreferences']),
      duration: (json['duration'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
      polilynePoints: (json['polilynePoints'] as List).map((point) => LatLng(point['latitude'], point['longitude'])).toList(),
      documentId: json['documentId'],
    );
  }

  // Factory constructor para crear un EcoCityTour desde un documento de Firestore
  factory EcoCityTour.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EcoCityTour(
      documentId: doc.id,
      city: data['city'],
      mode: data['mode'],
      userPreferences: List<String>.from(data['userPreferences']),
      duration: (data['duration'] as num?)?.toDouble(),
      distance: (data['distance'] as num?)?.toDouble(),
      polilynePoints: (data['polilynePoints'] as List)
          .map((point) => LatLng(point['lat'], point['lng']))
          .toList(),
      pois: (data['pois'] as List).map((poiData) {
        final poiGps = poiData['gps'];
        return PointOfInterest(
          gps: LatLng(poiGps['lat'], poiGps['lng']),
          name: poiData['name'],
          description: poiData['description'],
          url: poiData['url'],
          imageUrl: poiData['imageUrl'],
          rating: (poiData['rating'] as num?)?.toDouble(),
          address: poiData['address'],
          userRatingsTotal: poiData['userRatingsTotal'],
        );
      }).toList(),
    );
  }

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
