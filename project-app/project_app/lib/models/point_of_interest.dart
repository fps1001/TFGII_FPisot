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

// Método para convertir PointOfInterest a JSON
  Map<String, dynamic> toJson() {
    return {
      'gps': {'latitude': gps.latitude, 'longitude': gps.longitude},
      'name': name,
      'description': description,
      'url': url,
      'imageUrl': imageUrl,
      'rating': rating,
      'address': address,
      'userRatingsTotal': userRatingsTotal,
    };
  }

  // Método para crear una instancia de PointOfInterest desde JSON
  factory PointOfInterest.fromJson(Map<String, dynamic> json) {
    return PointOfInterest(
      gps: LatLng(json['gps']['latitude'], json['gps']['longitude']),
      name: json['name'],
      description: json['description'],
      url: json['url'],
      imageUrl: json['imageUrl'],
      rating: (json['rating'] as num?)?.toDouble(),
      address: json['address'],
      userRatingsTotal: json['userRatingsTotal'],
    );
  }

}
