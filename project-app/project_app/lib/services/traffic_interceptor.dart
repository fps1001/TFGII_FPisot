import 'package:dio/dio.dart';

// No funciona con variable de entorno.
const accessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
//const accessToken =     '';

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
