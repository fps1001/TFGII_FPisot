import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:project_app/logger/logger.dart';
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
      // Si la clave de la API está vacía, lanzamos un error y lo registramos
      log.e(
          'OptimizationService: No se encontró la clave API de Google Directions');
      throw AppException("Google API Key not found");
    }

    // Mapear los POIs a coordenadas LatLng
    final List<LatLng> points = pois.map((poi) => poi.gps).toList();

    // Formatear los puntos de interés para la solicitud a la API de Google
    final coorsString =
        points.map((point) => '${point.latitude},${point.longitude}').join('|');

    const url = 'https://maps.googleapis.com/maps/api/directions/json';

    try {
      log.i(
          'OptimizationService: Solicitando optimización de ruta para $city con modo $mode y ${pois.length} POIs');

      final response = await _dioOptimization.get(url, queryParameters: {
        'origin': '${points.first.latitude},${points.first.longitude}',
        'destination': '${points.last.latitude},${points.last.longitude}',
        'waypoints':
            'optimize:true|$coorsString', // Puedes eliminar 'optimize:true' si no es necesario
        'mode': mode,
        'key': apiKey,
      });

      log.d('Response data: ${response.data}');

      // Verificar si la respuesta contiene rutas
      if (response.data['routes'] == null || response.data['routes'].isEmpty) {
        log.w('OptimizationService: No se encontraron rutas en la respuesta');
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

      log.d(
          'OptimizationService: Ruta optimizada recibida. Distancia total: $distance m, Duración total: $duration segundos.');

      // Crear un EcoCityTour y retornarlo
      final ecoCityTour = EcoCityTour(
        city: city,
        pois: pois,
        mode: mode,
        userPreferences: userPreferences,
        duration: duration,
        distance: distance,
        polilynePoints: polilynePoints,
      );

      return ecoCityTour;
    } on DioException catch (e) {
      log.e(
          'OptimizationService: Error durante la solicitud a la API de Google Directions',
          error: e);
      throw DioExceptions.handleDioError(e, url: url);
    } catch (e, stackTrace) {
      log.e(
          'OptimizationService: Error desconocido durante la optimización de la ruta',
          error: e,
          stackTrace: stackTrace);
      throw AppException("An unknown error occurred", url: url);
    }
  }
}
