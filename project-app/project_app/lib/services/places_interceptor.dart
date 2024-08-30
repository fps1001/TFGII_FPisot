import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String placesAccessToken = dotenv.env['MAPBOX_API_KEY'] ?? '';

class PlacesInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll({
      'lenguage': 'es',
      'limit': '7',
      'access_token': placesAccessToken,
    });

    super.onRequest(options, handler);
  }
}
