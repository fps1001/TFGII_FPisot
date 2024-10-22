import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
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

  bool _isDialogShown = false; // Nueva bandera para evitar múltiples diálogos

  @override
  void initState() {
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
    locationBloc.startFollowingUser();

    // Inicializa la carga de puntos de interés (POIs) cuando se inicia la pantalla
    _initializeRouteAndPois();

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
      body: BlocListener<TourBloc, TourState>(
        listener: (context, tourState) {
          // Manejo del diálogo de carga
          if (tourState.isLoading && !_isDialogShown) {
            // Mostrar el diálogo de carga si no está ya mostrado
            _isDialogShown = true; // Marcar que el diálogo está mostrado
            LoadingMessageHelper.showLoadingMessage(context);
          } else if (!tourState.isLoading && _isDialogShown) {
            // Cerrar el diálogo de carga si ya no está cargando y el diálogo está mostrado
            _isDialogShown = false; // Marcar que el diálogo ya fue cerrado
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop(); // Cerrar el diálogo
            }
          }
        },
        child: BlocBuilder<LocationBloc, LocationState>(
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
                    BlocBuilder<TourBloc, TourState>(
                      builder: (context, tourState) {
                        // Mostrar el CustomSearchBar solo si el tourState no es null
                        if (tourState.ecoCityTour != null) {
                          return const Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            child:
                                CustomSearchBar(), // Barra de búsqueda personalizada
                          );
                        }
                        return const SizedBox
                            .shrink(); // Retorna un widget vacío si el tourState es null
                      },
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
                        // Mostrar el botón solo si el tourState.tour no es null y no está unido
                        if (tourState.ecoCityTour != null &&
                            !tourState.isJoined) {
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
                        return const SizedBox
                            .shrink(); // Si el usuario ya está unido o el tour es null, oculta el botón
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Método para cargar la ruta optimizada y los POIs
  Future<void> _initializeRouteAndPois() async {
    final mapBloc = BlocProvider.of<MapBloc>(context);

    // Pinta la nueva polilínea en el mapa usando el MapBloc
    log.i('MapScreen: Dibujando la ruta optimizada en el mapa.');
    await mapBloc.drawEcoCityTour(widget.tour);
    // Después de dibujar la ruta, mueve la cámara al primer POI si hay POIs
    if (widget.tour.pois.isNotEmpty) {
      final LatLng firstPoiLocation = widget.tour.pois.first.gps;
      log.i(
          'MapScreen: Moviendo la cámara al primer POI: ${widget.tour.pois.first.name}');
      mapBloc.moveCamera(firstPoiLocation); // Mover la cámara al primer POI
    }
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
