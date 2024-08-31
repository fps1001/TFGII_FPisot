import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchResult {
  //Determina si el usuario ha cancelado, si devuelve true, no debe hacer nada.
  final bool cancel;
  // busqueda manual
  final bool manual;
  // coordenadas
  final LatLng? position;
  final String? destinationName;
  final String? description;

  SearchResult({
    this.position, 
    this.destinationName, 
    this.description, 
    required this.cancel,
    this.manual = false
  });

  @override
  String toString() {
    return '{cancel: $cancel, manual: $manual}';
  }
}
