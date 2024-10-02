import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:project_app/exceptions/exceptions.dart';
import 'package:project_app/models/models.dart';

class OptimizationService {
  final Dio _dioOptimization;

  OptimizationService() : _dioOptimization = Dio();

  Future<EcoCityTour> getOptimizedRoute({
    required List<PointOfInterest> pois,
    required String mode,
    required String city,
    // Aunque no se necesitan para optimizar la ruta se dejan inalteradas para no perderlas.
    required List<String> userPreferences,
  }) async {
    String apiKey = dotenv.env['GOOGLE_DIRECTIONS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw AppException("Google API Key not found");
    }

    // Mapear los POIs a coordenadas LatLng
    final List<LatLng> points = pois.map((poi) => poi.gps).toList();

    // Formatear los puntos de interés para la solicitud a la API de Google
    final coorsString =
        points.map((point) => '${point.latitude},${point.longitude}').join('|');

    const url = 'https://maps.googleapis.com/maps/api/directions/json';

    try {
      final response = await _dioOptimization.get(url, queryParameters: {
        'origin': '${points.first.latitude},${points.first.longitude}',
        'destination': '${points.last.latitude},${points.last.longitude}',
        'waypoints':
            'optimize:true|$coorsString', // Puedes eliminar 'optimize:true' si no es necesario
        'mode': mode,
        'key': apiKey,
      });

      if (kDebugMode) {
        print(response.data);
      }

      // Verificar si la respuesta contiene rutas
      if (response.data['routes'] == null || response.data['routes'].isEmpty) {
        throw AppException("No routes found in response");
      }

      // Decodificar la polilínea
      final route = response.data['routes'][0];
      final polyline = route['overview_polyline']['points'];
      final polilynePoints = decodePolyline(polyline, accuracyExponent: 5)
          .map((coor) => LatLng(coor[0].toDouble(), coor[1].toDouble()))
          .toList();

      // Sumar la distancia y duración de todas las 'legs'
      final double distance = route['legs']
          .fold(0, (sum, leg) => sum + leg['distance']['value'])
          .toDouble();
      final double duration = route['legs']
          .fold(0, (sum, leg) => sum + leg['duration']['value'])
          .toDouble();

      // Crear un EcoCityTour y retornarlo
      final ecoCityTour = EcoCityTour(
        city: city,
        numberOfSites: pois.length,
        pois: pois,
        mode: mode,
        userPreferences: userPreferences,
        duration: duration,
        distance: distance,
        polilynePoints: polilynePoints,
      );

      return ecoCityTour;
    } on DioException catch (e) {
      throw DioExceptions.handleDioError(e, url: url);
    } catch (e) {
      throw AppException("An unknown error occurred", url: url);
    }
  }
}
