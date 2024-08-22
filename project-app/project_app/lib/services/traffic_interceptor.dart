import 'package:dio/dio.dart';

//const accessToken = 'YOUR_ACCESS_TOKEN_HERE';
final accessToken = const String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

class TrafficInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Construimos la misma petición con los parámetros como si fuera postman:
    options.queryParameters.addAll({
      'alternatives': 'true',
      'geometries': 'polyline6',
      'overview': 'simplified',
      'steps': 'false',
      'access_token': accessToken,
    });

    super.onRequest(options, handler);
  }
}
