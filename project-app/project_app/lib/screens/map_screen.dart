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
  bool isJoined = false; // Estado para saber si ya se ha unido

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
      appBar: const CustomAppBar(title: 'Eco City Tour'),
      // Cambio builder por FutureBuilder para cargar la ruta y los POIs porque se necesita esperar a que se carguen
      body: FutureBuilder<void>(
        future: _loadRouteAndPois, // future indica que se debe esperar a que se cargue la ruta y los POIs
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
            return const Center(child: Text('Error al cargar la ruta'));
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
                      // Añadimos los botones flotantes en la parte inferior derecha
                      const Positioned(
                        bottom: 90, // Ajustamos la posición para evitar solapamientos
                        right: 10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            BtnToggleUserRoute(),
                            SizedBox(height: 10), // Añadir espacio entre los botones
                            BtnFollowUser(),
                            SizedBox(height: 10),
                            BtnCurrentLocation(),
                          ],
                        ),
                      ),

                      // Añadir el botón de "Unirme al Eco City Tour" en la parte inferior
                      if (!isJoined) // Muestra el botón solo si no te has unido aún
                        Positioned(
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
                                // Aquí disparamos el evento para unirse al tour
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

    if (lastKnownLocation != null) {
      // Crear un PointOfInterest con la ubicación actual
      final newPoi = PointOfInterest(
        gps: lastKnownLocation,
        name: 'Ubicación actual', // Nombre del lugar
        description: 'Este es mi lugar actual',
        url: null,
        imageUrl: null, // No tienes una imagen para esto
        rating: null, // Sin calificación
      );

      // Añadir el POI al TourBloc
      BlocProvider.of<TourBloc>(context).add(OnAddPoiEvent(poi: newPoi));

      // Volver a pintar el mapa con el nuevo POI
      BlocProvider.of<MapBloc>(context).drawRoutePolyline(
        BlocProvider.of<TourBloc>(context).state.ecoCityTour!,
      );

      // Ocultar el botón después de que el usuario se haya unido
      setState(() {
        isJoined = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar( msg: 'No se encontró la ubicación actual.'),

      );
    }
  }

  @override
  void dispose() {
    locationBloc.stopFollowingUser();
    super.dispose();
  }
}
