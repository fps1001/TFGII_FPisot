import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/exceptions/exceptions.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/services.dart';

class TrafficService {
  final Dio _dioTraffic;
  final String _baseTrafficUrl = 'https://api.mapbox.com/directions/v5/mapbox';

  TrafficService() : _dioTraffic = Dio()..interceptors.add(TrafficInterceptor());

  Future<TrafficResponse> getCoorsStartToEnd(LatLng start, LatLng end) async {
    final coorsString =
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
    final url = '$_baseTrafficUrl/walking/$coorsString';

    try {
      final resp = await _dioTraffic.get(url);

      if (resp.data == null || resp.data['routes'] == null || resp.data['routes'].isEmpty) {
        throw AppException("No routes found in response", url: url);
      }

      final data = TrafficResponse.fromJson(resp.data);
      return data;
    } on DioException catch (e) {
      throw DioExceptions.handleDioError(e, url: url);
    } catch (e) {
      throw AppException("An unknown error occurred", url: url);
    }
  }
}
