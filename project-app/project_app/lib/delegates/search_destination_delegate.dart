import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/models/models.dart';

/// [SearchDestinationDelegate] es una clase que extiende [SearchDelegate]
/// y se utiliza para manejar la lógica de búsqueda personalizada dentro de una
/// aplicación Flutter. Un [SearchDelegate] permite a los desarrolladores definir
/// cómo se deben presentar las sugerencias de búsqueda, los resultados y las acciones
/// relacionadas con la búsqueda.
///
/// Esta clase en particular implementa un delegado de búsqueda simple que proporciona
/// acciones como limpiar la búsqueda, volver a la pantalla anterior, y mostrar una sugerencia
/// específica para colocar una ubicación manualmente.
///
///
/// El constructor de [SearchDestinationDelegate] define la etiqueta del campo de búsqueda
/// como "Buscar...".
class SearchDestinationDelegate extends SearchDelegate<SearchResult> {
  SearchDestinationDelegate() : super(searchFieldLabel: 'Buscar...');

  /// Este método construye las acciones que aparecerán a la derecha del campo de búsqueda.
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          }),
    ];
  }

  /// Este método construye el ícono que aparece a la izquierda del campo de búsqueda.
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () {
          final result = SearchResult(cancel: true);
          close(context, result);
        });
  }

  /// Este método construye los resultados de la búsqueda basados en la consulta del usuario.
  @override
  Widget buildResults(BuildContext context) {
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    // La proximidad la voy a obtener del bloc location: lastknownlocation.
    final proximity =
        BlocProvider.of<LocationBloc>(context).state.lastKnownLocation!;

    searchBloc.getPlacesByQuery(proximity, query);

    return BlocBuilder<SearchBloc, SearchState>(builder: (context, state) {
      final places = state.places;

      return ListView.separated(
        itemCount: places.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final place = places[index];
          return ListTile(
            leading: const Icon(Icons.place_outlined, color: Colors.black),
            title: Text(place.text, style: const TextStyle(color: Colors.black)),
            subtitle: Text(place.placeName,
                style: const TextStyle(color: Colors.black)),
            onTap: () {
              // TODO - Implementar lógica para seleccionar un lugar (mandar las coordenadas...)
              // Usuario ha seleccionado un lugar
              //final result = SearchResult(cancel: false, manual: false, place: place);
              //close(context, result);
            },
          );
        },
      );
    });
  }

  /// Este método construye las sugerencias de búsqueda mientras el usuario escribe.
  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.location_on_outlined, color: Colors.black),
          title: const Text('Colocar ubicación manualmente',
              style: TextStyle(color: Colors.black)),
          onTap: () {
            // Usuario está buscando...
            final result = SearchResult(cancel: false, manual: true);
            close(context, result);
          },
        )
      ],
    );
  }
}
