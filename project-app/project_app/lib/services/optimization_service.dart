import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/exceptions/exceptions.dart';
import 'package:project_app/models/models.dart';



class OptimizationService {
  final Dio _dioOptimization;

  final String _baseOptimizationUrl =
      'https://api.mapbox.com/optimized-trips/v1/mapbox';

  OptimizationService() : _dioOptimization = Dio();

  Future<OptimizationResponse> getOptimizedRoute(List<LatLng> points, String mode) async {
    final coorsString =
        points.map((point) => '${point.longitude},${point.latitude}').join(';');
    // Construimos la URL con los puntos y el modo de transporte
    final url = '$_baseOptimizationUrl/$mode/$coorsString';

    try {
      String accessToken = dotenv.env['MAPBOX_API_KEY'] ?? '';
      final resp = await _dioOptimization.get(url,  
      queryParameters: {
        'geometries': 'polyline6', 
        'source' : 'first',
        'destination' : 'any',
        'access_token': accessToken,
        });

      if (resp.data == null ||
          resp.data['trips'] == null ||
          resp.data['trips'].isEmpty) {
        throw AppException("No routes found in response", url: url);
      }

      final data = OptimizationResponse.fromJson(resp.data);
      return data;
    } on DioException catch (e) {
      throw DioExceptions.handleDioError(e, url: url);
    } catch (e) {
      throw AppException("An unknown error occurred", url: url);
    }
  }
}
