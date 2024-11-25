import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
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
    _initializeRouteAndPois();
    log.i('MapScreen: Inicializado para el EcoCityTour en ${widget.tour.city}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TourBloc, TourState>(
            listener: (context, state) => _handleLoadingState(state),
          ),
        ],
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, locationState) {
            if (locationState.lastKnownLocation == null) {
              return _buildLoadingTourMessage(context);
            }
            return _buildMapView(locationState);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: BlocBuilder<TourBloc, TourState>(
        builder: (context, tourState) {
          return CustomAppBar(
            title: 'Eco City Tour',
            tourState: tourState,
          );
        },
      ),
    );
  }

  void _handleLoadingState(TourState state) {
    if (state.isLoading && !_isDialogShown) {
      _isDialogShown = true;
      LoadingMessageHelper.showLoadingMessage(context);
    } else if (!state.isLoading && _isDialogShown) {
      _isDialogShown = false;
      if (Navigator.canPop(context)) Navigator.of(context).pop();
    }
  }

  Widget _buildMapView(LocationState locationState) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, mapState) {
        return Stack(
          children: [
            MapView(
              initialPosition: locationState.lastKnownLocation!,
              polylines: mapState.polylines.values.toSet(),
              markers: mapState.markers.values.toSet(),
            ),
            _buildSearchBar(),
            _buildMapButtons(),
            _buildJoinTourButton(),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return BlocBuilder<TourBloc, TourState>(
      builder: (context, state) {
        if (state.ecoCityTour != null) {
          return const Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: CustomSearchBar(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

 Widget _buildMapButtons() {
  return const Positioned(
    bottom: 90, // Aumentamos el valor para separar los botones del botón principal
    right: 10,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        BtnToggleUserRoute(),
        SizedBox(height: 15), // Más espacio entre los botones
        BtnFollowUser(),
      ],
    ),
  );
}

Widget _buildJoinTourButton() {
  return BlocBuilder<TourBloc, TourState>(
    builder: (context, state) {
      if (state.ecoCityTour != null && !state.isJoined) {
        return Positioned(
          bottom: 40, // Ajustamos el valor para no solapar con los otros botones
          left: 32,
          right: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
  );
}


  Widget _buildLoadingTourMessage(BuildContext context) {
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
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Esperando la ubicación para mostrar el tour. Por favor, asegúrate de que el GPS está activado.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeRouteAndPois() async {
    final mapBloc = BlocProvider.of<MapBloc>(context);

    log.i('MapScreen: Dibujando ruta optimizada.');
    await mapBloc.drawEcoCityTour(widget.tour);

    if (widget.tour.pois.isNotEmpty) {
      mapBloc.moveCamera(widget.tour.pois.first.gps);
    }
  }

  void _joinEcoCityTour() {
    final lastKnownLocation = locationBloc.state.lastKnownLocation;

    if (lastKnownLocation == null) {
      _showSnackbar('No se encontró la ubicación actual.');
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

    log.i('Añadiendo ubicación actual al tour.');
    BlocProvider.of<TourBloc>(context).add(OnAddPoiEvent(poi: newPoi));
    BlocProvider.of<TourBloc>(context).add(const OnJoinTourEvent());
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar(msg: message));
  }

  @override
  void dispose() {
    locationBloc.stopFollowingUser();
    log.i('MapScreen: Cerrando pantalla y deteniendo seguimiento.');
    super.dispose();
  }
}
