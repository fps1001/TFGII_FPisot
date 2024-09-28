import 'package:google_maps_flutter/google_maps_flutter.dart';

class PointOfInterest {
  final LatLng gps;
  final String name;
  final String? description;
  final String? url;
  final String? imageUrl;  // Será la URL completa de la imagen.
  final double? rating;
  final String? address;
  //final String? iconUrl;
  //final String? businessStatus;
  //final List<String>? types;
  //final String? placeId;
  //final String? plusCode;
  //final bool? openNow;
  final int? userRatingsTotal;

  PointOfInterest({
    required this.gps,
    required this.name,
    this.description,
    this.url,
    this.imageUrl,
    this.rating,
    this.address,
    //this.iconUrl,
    //this.businessStatus,
    //this.types,
    //this.placeId,
    //this.plusCode,
    //this.openNow,
    this.userRatingsTotal,
  });

}
