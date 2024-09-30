import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/blocs/blocs.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Eco City Tour',
        onBackPressed: () {
          // Limpiamos el estado del TourBloc al regresar
          BlocProvider.of<TourBloc>(context).add(const ResetTourEvent());

          // Luego, navegamos de regreso
          Navigator.of(context).pop();
        },
      ),

      // Cambio builder por FutureBuilder para cargar la ruta y los POIs porque se necesita esperar a que se carguen
      body: FutureBuilder<void>(
        future:
            _loadRouteAndPois, // future indica que se debe esperar a que se cargue la ruta y los POIs
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostrar el diálogo de carga mientras esperamos los POIs y la ruta optimizada
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                // Verificar si el widget sigue montado
                LoadingMessageHelper.showLoadingMessage(context);
              }
            });
            return const SizedBox(); // Devolvemos un widget vacío mientras se muestra el diálogo
          }

          if (snapshot.hasError) {
            if (mounted) {
              // Verificar si el widget sigue montado
              Navigator.of(context).pop(); // Cerrar el diálogo si hay un error
            }
            return const Center(child: Text('Error al cargar la ruta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00A86B)), ));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            // Cerrar el mensaje de carga una vez que la ruta esté lista
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                // Verificar si el widget sigue montado
                Navigator.of(context).pop(); // Cerrar el mensaje de carga
              }
            });
          }

          // Obtener el estado de ubicación usando BlocBuilder
          return BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locationState) {
              if (locationState.lastKnownLocation == null) {
                return const Center(
                  //* Si lo pongo según context me da el error de native socket... lo dejo hardcoded
                  child: Text('Presentando nuevo Eco City Tour...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00A86B)), ),
                );
              }

              // Mapa listo para ser mostrado
              return BlocBuilder<MapBloc, MapState>(
                builder: (context, mapState) {
                  // Calcular si se debe mostrar la ruta del usuario
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
                     // Añadir los botones flotantes en la parte inferior derecha
                      BlocBuilder<TourBloc, TourState>(
                        builder: (context, tourState) {
                          return Positioned(
                            bottom: tourState.isJoined ? 30 : 90,  // Cambia la posición si el usuario está unido o no
                            right: 10,
                            child: const Column(
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
                        },
                      ),
                      // Añadir el botón de "Unirme al Eco City Tour" en la parte inferior
                      BlocBuilder<TourBloc, TourState>(
                        builder: (context, tourState) {
                          if (!tourState.isJoined) {
                            return Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
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
                          return const SizedBox.shrink(); // No muestra el botón si ya está unido
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
    await mapBloc.drawRoutePolyline(widget.tour);
  }

  /// Función que añade un nuevo POI al Eco City Tour basado en la ubicación actual del usuario
  void _joinEcoCityTour() {
    final lastKnownLocation = locationBloc.state.lastKnownLocation;

    if (lastKnownLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar(msg: 'No se encontró la ubicación actual.'),
      );
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

    // Añadir el POI al TourBloc
    BlocProvider.of<TourBloc>(context).add(OnAddPoiEvent(poi: newPoi));

    // Cambiar el estado de isJoined después de añadir el POI
    BlocProvider.of<TourBloc>(context).add(const OnJoinTourEvent());
  }

  @override
  void dispose() {
    locationBloc.stopFollowingUser();
    super.dispose();
  }
}
