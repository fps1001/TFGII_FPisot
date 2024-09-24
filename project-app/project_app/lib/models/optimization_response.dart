import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

class OptimizationResponse {
  final List<LatLng> points;
  final double distance;
  final double duration;

  OptimizationResponse({
    required this.points,
    required this.distance,
    required this.duration,
  });

  factory OptimizationResponse.fromGoogleJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final polyline = route['overview_polyline']['points'];
    final points = decodePolyline(polyline, accuracyExponent: 5)
        .map((coor) => LatLng(coor[0].toDouble(), coor[1].toDouble()))
        .toList();

    final distance = route['legs'].fold(0, (sum, leg) => sum + leg['distance']['value']);
    final duration = route['legs'].fold(0, (sum, leg) => sum + leg['duration']['value']);

    return OptimizationResponse(
      points: points,
      distance: distance.toDouble(),
      duration: duration.toDouble(),
    );
  }
}
