import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/exceptions/exceptions.dart';
import 'package:project_app/models/models.dart';



class OptimizationService {
  final Dio _dioOptimization;

  final String _baseOptimizationUrl =
      'https://api.mapbox.com/optimized-trips/v1/{mapbox/walking}';

  OptimizationService() : _dioOptimization = Dio();

  Future<OptimizationResponse> getOptimizedRoute(List<LatLng> points) async {
    final coorsString =
        points.map((point) => '${point.longitude},${point.latitude}').join(';');
    final url = '$_baseOptimizationUrl/$coorsString';

    try {
      final resp = await _dioOptimization.get(url,  
      queryParameters: {
        'geometries': 'polyline6', 
        'source' : 'first',
        'destination' : 'any',
        });

      if (resp.data == null ||
          resp.data['routes'] == null ||
          resp.data['routes'].isEmpty) {
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
