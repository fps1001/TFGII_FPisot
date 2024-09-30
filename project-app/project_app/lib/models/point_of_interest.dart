import 'package:google_maps_flutter/google_maps_flutter.dart';

class PointOfInterest {
  final LatLng gps;
  final String name;
  final String? description;
  final String? url;
  final String? imageUrl; 
  final double? rating;
  final String? address;
  final int? userRatingsTotal;

  PointOfInterest({
    required this.gps,
    required this.name,
    this.description,
    this.url,
    this.imageUrl,
    this.rating,
    this.address,
    this.userRatingsTotal,
  });

}
