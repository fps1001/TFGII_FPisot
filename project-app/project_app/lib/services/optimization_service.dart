import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/exceptions/exceptions.dart';
import 'package:project_app/models/models.dart';

class OptimizationService {
  final Dio _dioOptimization;

  OptimizationService() : _dioOptimization = Dio();

  Future<OptimizationResponse> getOptimizedRoute(List<LatLng> points, String mode) async {
    String apiKey = dotenv.env['GOOGLE_DIRECTIONS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw AppException("Google API Key not found");
    }

    final coorsString = points.map((point) => '${point.latitude},${point.longitude}').join('|');
    
    const url = 'https://maps.googleapis.com/maps/api/directions/json';

    try {
      final response = await _dioOptimization.get(url, queryParameters: {
        'origin': '${points.first.latitude},${points.first.longitude}',
        'destination': '${points.last.latitude},${points.last.longitude}',
        'waypoints': 'optimize:true|$coorsString',
        'mode': mode,
        'key': apiKey,
      });
      print(response.data); // Para inspeccionar la respuesta completa

      if (response.data['routes'] == null || response.data['routes'].isEmpty) {
        throw AppException("No routes found in response");
      }

      final data = OptimizationResponse.fromGoogleJson(response.data);
      return data;
    } on DioException catch (e) {
      throw DioExceptions.handleDioError(e, url: url);
    } catch (e) {
      throw AppException("An unknown error occurred", url: url);
    }
  }
}
