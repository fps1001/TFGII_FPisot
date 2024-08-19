class SearchResult {
  //Determina si el usuario ha cancelado, si devuelve true, no debe hacer nada.
  final bool cancel;
  // busqueda manual
  final bool manual;

  SearchResult({required this.cancel, this.manual = false});

  //TODO: nombre, descripcion, latlong...

  @override
  String toString() {
    return '{cancel: $cancel, manual: $manual}';
  }
}
