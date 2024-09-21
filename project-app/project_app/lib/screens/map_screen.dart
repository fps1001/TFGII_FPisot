import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/blocs/blocs.dart';

import 'package:project_app/views/views.dart';
import 'package:project_app/widgets/widgets.dart';

import '../helpers/helpers.dart';
import '../models/models.dart';

class MapScreen extends StatefulWidget {
  final String city;
  final int numberOfSites;
  final List<PointOfInterest> pois; // Recibimos poi de LLM a través de pantalla de selección de tours
  
  const MapScreen({
    Key? key,
    required this.city,
    required this.numberOfSites,
    required this.pois,

  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LocationBloc locationBloc;
  late Future<void> _loadRouteAndPois;

  @override
  void initState() {
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
    locationBloc.startFollowingUser();

    // Inicializa la carga de puntos de interés (POIs) cuando se inicia la pantalla, pero después de que se haya iniciado la localización.
    _loadRouteAndPois = _initializeRouteAndPois();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Eco City Tour'), // Usa el CustomAppBar
      //TODO añadir un drawer para la selección de tours
      
      // Cambio builder por futurebuilder para cargar la ruta y los POIs porque se necesita esperar a que se carguen
      body: FutureBuilder<void>(
        future: _loadRouteAndPois, //future indica que se debe esperar a que se cargue la ruta y los POIs
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostrar el diálogo de carga mientras esperamos los POIs y la ruta optimizada
            WidgetsBinding.instance.addPostFrameCallback((_) {
              LoadingMessageHelper.showLoadingMessage(context);
            });
            return const SizedBox(); // Devolvemos un widget vacío mientras se muestra el diálogo
          }
          if (snapshot.hasError) {
            Navigator.of(context).pop(); // Cerrar el diálogo si hay un error
            return const Center(child: Text('Error al cargar la ruta'));
          }

          // Cerrar el mensaje de carga una vez que la ruta esté lista
          if (snapshot.connectionState == ConnectionState.done) {
            Navigator.of(context).pop();
          }
          // Obtener el estado de ubicación usando BlocBuilder
          return BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locationState) {
              if (locationState.lastKnownLocation == null) {
                return const Center(
                  child: Text('Espere por favor...'),
                );
              }

              // Mapa listo para ser mostrado
              return BlocBuilder<MapBloc, MapState>(
                builder: (context, mapState) {
                  // Calcular si se debe mostrar la ruta del usuario
                  Map<String, Polyline> polylines = Map.from(mapState.polylines);
                  if (!mapState.showUserRoute) {
                    polylines.removeWhere((key, value) => key == 'myRoute');
                  }
                  return Stack(
                    children: [
                      MapView(
                        initialPosition: locationState.lastKnownLocation!,
                        polylines: polylines.values.toSet(),
                        markers: mapState.markers.values.toSet(),
                      ),
                      const CustomSearchBar(),
                      const ManualMarker(),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BtnTest(),
          BtnToggleUserRoute(),
          BtnFollowUser(),
          BtnCurrentLocation(),
        ],
      ),
    );
  }

  /// Método para cargar la ruta optimizada y los POIs
  Future<void> _initializeRouteAndPois() async {
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final locationBloc = BlocProvider.of<LocationBloc>(context);

    // Obtener la última ubicación conocida
    final lastKnownLocation = locationBloc.state.lastKnownLocation;

    // Añadir la ubicación del usuario como el primer POI si existe
    final List<PointOfInterest> allPOIs = lastKnownLocation != null
        ? [
            PointOfInterest(
              gps: lastKnownLocation,
              name: 'Tu ubicación actual',
              description: 'Última ubicación conocida del usuario',
            ),
            ...widget.pois
          ]
        : widget.pois;

    // Convertir la lista de PointOfInterest a una lista de LatLng
    final List<LatLng> coordinates = allPOIs.map((poi) => poi.gps).toList();

    // Obtener la ruta optimizada usando los POIs
    final destination = await searchBloc.getOptimizedRoute(coordinates);

    // Pintar la nueva polilínea en el mapa usando el MapBloc
    await mapBloc.drawRoutePolyline(destination, allPOIs);
  }

  @override
  void dispose() {
    locationBloc.stopFollowingUser();
    super.dispose();
  }
}
