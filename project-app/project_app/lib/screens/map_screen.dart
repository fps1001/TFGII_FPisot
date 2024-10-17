import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/logger/logger.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/helpers/helpers.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/ui/ui.dart';
import 'package:project_app/views/views.dart';
import 'package:project_app/widgets/widgets.dart';

class MapScreen extends StatefulWidget {
  final EcoCityTour tour;

  const MapScreen({
    super.key,
    required this.tour,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LocationBloc locationBloc;
  late Future<void> _loadRouteAndPois;
  bool _isLoading = true; // Nueva bandera para controlar el estado de carga

  @override
  void initState() {
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
    locationBloc.startFollowingUser();

    // Inicializa la carga de puntos de interés (POIs) cuando se inicia la pantalla
    _loadRouteAndPois = _initializeRouteAndPois();

    // Log para el inicio del mapa con el tour
    log.i(
        'MapScreen: Iniciando la pantalla del mapa para el EcoCityTour en ${widget.tour.city}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Eco City Tour',
        tourState: BlocProvider.of<TourBloc>(context)
            .state, // Pasamos el estado del tour
      ),
      body: FutureBuilder<void>(
        future: _loadRouteAndPois, // Esperar a que se cargue la ruta y los POIs
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _isLoading) {
            // Mostrar el diálogo de carga mientras se espera que los POIs y la ruta se carguen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                LoadingMessageHelper.showLoadingMessage(context);
                log.i('MapScreen: Cargando la ruta y los POIs...');
              }
            });
            return const SizedBox(); // Widget vacío mientras se muestra el diálogo
          }

          if (snapshot.hasError) {
            // Si ocurre un error, cierra el diálogo y muestra un mensaje de error
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pop(); // Cerrar el diálogo de carga
                log.e('MapScreen: Error al cargar la ruta: ${snapshot.error}');
              }
            });
            return const Center(
              child: Text(
                'Error al cargar la ruta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A86B),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            // Cerrar el diálogo de carga una vez que la ruta esté lista
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _isLoading) {
                Navigator.of(context).pop(); // Cerrar el diálogo de carga
                _isLoading =
                    false; // Actualizamos el estado para indicar que la carga ha finalizado
                log.i('MapScreen: Ruta y POIs cargados correctamente.');
              }
            });
          }

          // Mostrar el contenido del mapa y lógica de BlocBuilders aquí
          return BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locationState) {
              if (locationState.lastKnownLocation == null) {
                return const Center(
                  child: Text(
                    'Presentando nuevo Eco City Tour...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00A86B),
                    ),
                  ),
                );
              }

              return BlocBuilder<MapBloc, MapState>(
                builder: (context, mapState) {
                  Map<String, Polyline> polylines =
                      Map.from(mapState.polylines);
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
                      const Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child:
                            CustomSearchBar(), // Barra de búsqueda personalizada
                      ),
                      BlocBuilder<TourBloc, TourState>(
                        builder: (context, tourState) {
                          return Positioned(
                            bottom: tourState.isJoined ? 30 : 90,
                            right: 10,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                BtnToggleUserRoute(),
                                SizedBox(height: 10),
                                BtnFollowUser(),
                              ],
                            ),
                          );
                        },
                      ),
                      BlocBuilder<TourBloc, TourState>(
                        builder: (context, tourState) {
                          if (!tourState.isJoined) {
                            return Positioned(
                              bottom: 20,
                              left: 32,
                              right: 32,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: MaterialButton(
                                  color: Theme.of(context).primaryColor,
                                  height: 50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  onPressed: () {
                                    _joinEcoCityTour();
                                  },
                                  child: const Text(
                                    'Unirme al Eco City Tour',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Método para cargar la ruta optimizada y los POIs
  Future<void> _initializeRouteAndPois() async {
    final mapBloc = BlocProvider.of<MapBloc>(context);

    // Pinta la nueva polilínea en el mapa usando el MapBloc
    log.i('MapScreen: Dibujando la ruta optimizada en el mapa.');
    await mapBloc.drawEcoCityTour(widget.tour);
  }

  /// Función que añade un nuevo POI al Eco City Tour basado en la ubicación actual del usuario
  void _joinEcoCityTour() {
    final lastKnownLocation = locationBloc.state.lastKnownLocation;

    if (lastKnownLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar(msg: 'No se encontró la ubicación actual.'),
      );
      log.w(
          'MapScreen: Intento fallido de unirse al EcoCityTour, no se encontró la ubicación actual.');
      return;
    }

    // Crear un PointOfInterest con la ubicación actual
    final newPoi = PointOfInterest(
      gps: lastKnownLocation,
      name: 'Ubicación actual',
      description: 'Este es mi lugar actual',
      url: null,
      imageUrl: null,
      rating: 5.0,
    );

    log.i('MapScreen: Añadiendo la ubicación actual al EcoCityTour como POI.');

    // Añadir el POI al TourBloc
    BlocProvider.of<TourBloc>(context).add(OnAddPoiEvent(poi: newPoi));

    // Cambiar el estado de isJoined después de añadir el POI
    BlocProvider.of<TourBloc>(context).add(const OnJoinTourEvent());
  }

  @override
  void dispose() {
    locationBloc.stopFollowingUser();
    log.i(
        'MapScreen: Deteniendo el seguimiento de ubicación y saliendo de la pantalla del mapa.');
    super.dispose();
  }
}
