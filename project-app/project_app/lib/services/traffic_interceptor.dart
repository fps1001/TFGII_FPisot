import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String accessToken = dotenv.env['MAPBOX_API_KEY'] ?? '';

class TrafficInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Construimos la misma petición con los parámetros como si fuera postman:
    options.queryParameters.addAll({
      'alternatives': true,
      'geometries': 'polyline6',
      'overview': 'simplified',
      'steps': false,
      //'continue_straight': true,
      'access_token': accessToken,
    });

    super.onRequest(options, handler);
  }
}
