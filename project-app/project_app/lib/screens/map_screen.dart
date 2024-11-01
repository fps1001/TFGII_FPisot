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

  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
    locationBloc.startFollowingUser();

    // Inicializa la carga de puntos de interés (POIs) cuando se inicia la pantalla
    _initializeRouteAndPois();

    log.i(
        'MapScreen: Iniciando la pantalla del mapa para el EcoCityTour en ${widget.tour.city}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<TourBloc, TourState>(
          builder: (context, tourState) {
            return CustomAppBar(
              title: 'Eco City Tour',
              tourState: tourState, // Usamos el estado actual del tour
            );
          },
        ),
      ),
      body: BlocListener<TourBloc, TourState>(
        listener: (context, tourState) {
          // Manejo del diálogo de carga
          if (tourState.isLoading && !_isDialogShown) {
            _isDialogShown = true;
            LoadingMessageHelper.showLoadingMessage(context);
          } else if (!tourState.isLoading && _isDialogShown) {
            _isDialogShown = false;
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          }
        },
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, locationState) {
            if (locationState.lastKnownLocation == null) {
              return _buildPresentingNewTourState(context);
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
                        if (tourState.ecoCityTour != null) {
                          return const Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            child: CustomSearchBar(),
                          );
                        }
                        return const SizedBox.shrink();
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
                                onPressed: _joinEcoCityTour,
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
        ),
      ),
    );
  }

  Future<void> _initializeRouteAndPois() async {
    final mapBloc = BlocProvider.of<MapBloc>(context);

    log.i('MapScreen: Dibujando la ruta optimizada en el mapa.');
    await mapBloc.drawEcoCityTour(widget.tour);
    if (widget.tour.pois.isNotEmpty) {
      final LatLng firstPoiLocation = widget.tour.pois.first.gps;
      log.i(
          'MapScreen: Moviendo la cámara al primer POI: ${widget.tour.pois.first.name}');
      mapBloc.moveCamera(firstPoiLocation);
    }
  }

  Widget _buildPresentingNewTourState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined,
                size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            Text(
              'Presentando nuevo Eco City Tour...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Esperando la ubicación para mostrar el tour. Por favor, asegúrate de que el GPS está activado.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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

    final newPoi = PointOfInterest(
      gps: lastKnownLocation,
      name: 'Ubicación actual',
      description: 'Este es mi lugar actual',
      url: null,
      imageUrl: null,
      rating: 5.0,
    );

    log.i('MapScreen: Añadiendo la ubicación actual al EcoCityTour como POI.');
    BlocProvider.of<TourBloc>(context).add(OnAddPoiEvent(poi: newPoi));
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
