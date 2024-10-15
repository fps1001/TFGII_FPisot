import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger para registrar eventos
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/screens/screens.dart';
import 'package:project_app/ui/ui.dart';
import 'package:project_app/views/views.dart';
import 'package:project_app/widgets/widgets.dart';

import '../helpers/helpers.dart';
import '../models/models.dart';

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

  @override
  void initState() {
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
    locationBloc.startFollowingUser();

    // Inicializa la carga de puntos de interés (POIs) cuando se inicia la pantalla, pero después de que se haya iniciado la localización.
    _loadRouteAndPois = _initializeRouteAndPois();

    // Log para el inicio del mapa con el tour
    log.i(
        'MapScreen: Iniciando la pantalla del mapa para el EcoCityTour en ${widget.tour.city}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FutureBuilder<void>(
        future: _loadRouteAndPois,
        builder: (context, snapshot) {
          return _buildFutureContent(context, snapshot);
        },
      ),
    );
  }

  CustomAppBar _buildAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'Eco City Tour',
      onBackPressed: () {
        log.i('MapScreen: Regresando a la selección de EcoCityTour.');
        BlocProvider.of<TourBloc>(context).add(const ResetTourEvent());
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TourSelectionScreen()),
          (route) => false,
        );
      },
      actions: [
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: () {
            log.i('MapScreen: Abriendo resumen del EcoCityTour');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TourSummary(tour: widget.tour),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFutureContent(
      BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _showLoading(context);
    } else if (snapshot.hasError) {
      return _showError(context, snapshot.error);
    } else if (snapshot.connectionState == ConnectionState.done) {
      return _buildMapView(context);
    }
    return const SizedBox();
  }

  Widget _showLoading(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        LoadingMessageHelper.showLoadingMessage(context);
        log.i('MapScreen: Cargando la ruta y los POIs...');
      }
    });
    return const SizedBox();
  }

  Widget _showError(BuildContext context, Object? error) {
    if (mounted) {
      Navigator.of(context).pop();
    }
    log.e('MapScreen: Error al cargar la ruta: $error');
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

  Widget _buildMapView(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop();
        log.i('MapScreen: Ruta y POIs cargados correctamente.');
      }
    });
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, locationState) {
        if (locationState.lastKnownLocation == null) {
          return _showNoLocationMessage();
        }
        return _buildMapWithPolylines(context, locationState);
      },
    );
  }

  Widget _showNoLocationMessage() {
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

  Widget _buildMapWithPolylines(
      BuildContext context, LocationState locationState) {
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
            _buildFloatingButtons(context),
            _buildJoinTourButton(context),
          ],
        );
      },
    );
  }

  Widget _buildFloatingButtons(BuildContext context) {
    return const Positioned(
      bottom: 30,
      right: 10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BtnToggleUserRoute(),
          SizedBox(height: 10),
          BtnFollowUser(),
          SizedBox(height: 10),
          BtnCurrentLocation(),
        ],
      ),
    );
  }

  Widget _buildJoinTourButton(BuildContext context) {
    return BlocBuilder<TourBloc, TourState>(
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
      name: 'Ubicación actual', // Nombre del lugar
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
