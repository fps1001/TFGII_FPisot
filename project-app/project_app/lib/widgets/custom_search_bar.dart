import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/delegates/delegates.dart';
import 'package:project_app/models/models.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return state.displayManualMarker
            ? const SizedBox()
            : FadeInDown(
                duration: const Duration(milliseconds: 300),
                child: _CustomSearchBarBody());
      },
    );
  }
}

class _CustomSearchBarBody extends StatelessWidget {
  // Función que determinará si mostrar el marcador manual en función del SearchBloc o mostrar polilínea de resultado.
  void onSearchResults(BuildContext context, SearchResult result) async {
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final start =   BlocProvider.of<LocationBloc>(context).state.lastKnownLocation;
    if (result.manual == true) {
      // Lanza el evento que cambiará el estado.
      searchBloc.add(OnActivateManualMarkerEvent());
      return;
    }
    if (result.position != null && start != null) {
      // Calcula la polilínea a mostrar por el mapbloc
      final destination = await searchBloc.getCoorsStartToEnd(start, result.position!);
      // Se llama a pintar nueva polilínea:
      await mapBloc.drawRoutePolyline(destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    // SafeArea para asegurar que no choca con parte de arriba.
    return SafeArea(
      child: Container(
        margin: const EdgeInsetsDirectional.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        width: double.infinity,
        child: GestureDetector(
            onTap: () async {
              final result = await showSearch(
                  context: context, delegate: SearchDestinationDelegate());
              // si el objeto no vuelve no hay que hacer nada.
              if (result == null) return;

              // ignore: use_build_context_synchronously
              onSearchResults(context, result);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 5))
                  ]),
              child: const Text('¿Dónde quieres ir?',
                  style: TextStyle(color: Colors.black87)),
            )),
      ),
    );
  }
}
