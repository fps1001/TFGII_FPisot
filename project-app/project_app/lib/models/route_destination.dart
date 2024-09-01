// Clase para la obtención de puntos que determine la geometría que se debe generar en la aplicación.
// Transforma el TrafficResponse en RouteDestination es decir el modelado de la respuesta a la petición GET en un modelo que determine las coordenadas.
// Estructurar así hace más fácil cambiar de provedor de servicio de geocoding.
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:project_app/models/models.dart';

class RouteDestination {
  final List<LatLng> points;
  final double duration;
  final double distance;
  final Feature endPlace;  

  RouteDestination({
    required this.points,
    required this.duration,
    required this.distance,
    required this.endPlace,
  });
}
