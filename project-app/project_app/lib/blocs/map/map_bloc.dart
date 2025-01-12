import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/helpers/custom_image_marker.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/logger/logger.dart';
import 'package:project_app/widgets/widgets.dart';

part 'map_event.dart';
part 'map_state.dart';

/// [MapBloc] gestiona el estado y la lógica relacionada con el mapa de la aplicación.
///
/// Este bloc se encarga de:
/// - Dibujar polilíneas (rutas) y marcadores en el mapa.
/// - Controlar la cámara del mapa (movimientos y zoom).
/// - Seguir la ubicación del usuario.
/// - Mostrar y ocultar rutas.
/// - Administrar eventos relacionados con el mapa.
class MapBloc extends Bloc<MapEvent, MapState> {
  /// Controlador para manejar el mapa de Google Maps.
  GoogleMapController? _mapController;

  /// Bloc de ubicación para obtener datos de la posición del usuario.
  final LocationBloc locationBloc;

  /// Suscripción para escuchar los cambios de estado del [LocationBloc].
  StreamSubscription<LocationState>? locationSubscription;

  /// Coordenadas actuales del centro del mapa.
  LatLng? mapCenter;

  /// Constructor del [MapBloc].
  ///
  /// Requiere un [LocationBloc] para obtener datos de la ubicación del usuario.
  MapBloc({required this.locationBloc}) : super(const MapState()) {
    // Manejo de eventos del MapBloc
    on<OnMapInitializedEvent>(_onInitMap);
    on<OnStartFollowingUserEvent>(_onStartFollowingUser);
    on<OnStopFollowingUserEvent>(
        (event, emit) => emit(state.copyWith(isFollowingUser: false)));
    on<OnUpdateUserPolylinesEvent>(_onPolylineNewPoint);
    on<OnDisplayPolylinesEvent>((event, emit) {
      final currentPolylines = Map<String, Polyline>.from(event.polylines);

      // Si la ruta del usuario no debe mostrarse, eliminar 'myRoute'
      if (!state.showUserRoute && currentPolylines.containsKey('myRoute')) {
        log.i(
            'Eliminando polilínea myRoute porque showUserRoute está desactivado.');
        currentPolylines.remove('myRoute');
      }

      emit(state.copyWith(polylines: currentPolylines, markers: event.markers));
    });

    on<OnToggleShowUserRouteEvent>((event, emit) =>
        emit(state.copyWith(showUserRoute: !state.showUserRoute)));
    on<OnRemovePoiMarkerEvent>(_onRemovePoiMarker);
    on<OnAddPoiMarkerEvent>(_onAddPoiMarker);
    on<OnClearMapEvent>(_onClearMap); // Limpia todos los elementos del mapa.

    // Escucha los cambios de ubicación en el LocationBloc
    locationSubscription = locationBloc.stream.listen((locationState) {
      if (locationState.lastKnownLocation != null) {
        log.i(
            'Añadiendo nueva polilínea con la ubicación del usuario: ${locationState.lastKnownLocation}');
        add(OnUpdateUserPolylinesEvent(locationState.myLocationHistory));
      }

      // Si no se está siguiendo al usuario, no mover la cámara.
      if (!state.isFollowingUser) return;
      if (locationState.lastKnownLocation == null) return;

      // Mueve la cámara al usuario si se está siguiendo.
      moveCamera(locationState.lastKnownLocation!);
    });
  }

  /// Inicializa el mapa con el controlador y el contexto.
  Future<void> _onInitMap(
      OnMapInitializedEvent event, Emitter<MapState> emit) async {
    _mapController = event.mapController;
    log.i('Mapa inicializado. Controlador del mapa establecido.');
    emit(state.copyWith(isMapInitialized: true, mapContext: event.mapContext));
  }

  /// Mueve la cámara del mapa a una ubicación específica.
  ///
  /// - [latLng]: Coordenadas a las que se moverá la cámara.
  Future<void> moveCamera(LatLng latLng) async {
    if (_mapController == null) {
      log.i('El controlador del mapa aún no está listo.');
      return;
    }
    log.i('Moviendo cámara a la posición: $latLng');
    final cameraUpdate = CameraUpdate.newLatLng(latLng);
    await _mapController?.animateCamera(cameraUpdate);
  }

  /// Comienza a seguir la ubicación del usuario.
  ///
  /// Mueve la cámara automáticamente al usuario cada vez que cambia su ubicación.
  Future<void> _onStartFollowingUser(
      OnStartFollowingUserEvent event, Emitter<MapState> emit) async {
    emit(state.copyWith(isFollowingUser: true));
    log.i('Comenzando a seguir al usuario.');
    if (locationBloc.state.lastKnownLocation == null) return;
    await moveCamera(locationBloc.state.lastKnownLocation!);
  }

  /// Actualiza la polilínea de la ruta del usuario con nuevas ubicaciones.
  ///
  /// Si `showUserRoute` está desactivado, no se dibuja la polilínea.
  void _onPolylineNewPoint(
      OnUpdateUserPolylinesEvent event, Emitter<MapState> emit) {
    log.i('Añadiendo nuevo punto a la polilínea.');

    if (!state.showUserRoute) {
      log.i('showUserRoute está desactivado. No se agrega la polilínea.');
      return; // Salir si la ruta del usuario no debe mostrarse.
    }

    final myRoute = Polyline(
      polylineId: const PolylineId('myRoute'),
      points: event.userLocations,
      width: 5,
      color: const Color.fromARGB(255, 207, 18, 135),
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    currentPolylines['myRoute'] = myRoute;

    emit(state.copyWith(polylines: currentPolylines));
  }

  /// Dibuja un EcoCityTour en el mapa, añadiendo polilíneas y marcadores.
  ///
  /// - [tour]: Contiene los puntos de interés y la ruta del tour.
  Future<void> drawEcoCityTour(EcoCityTour tour) async {
    log.i('Dibujando EcoCityTour en el mapa: ${tour.name}');

    // Crear la polilínea del tour.
    final myRoute = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.teal,
      width: 5,
      points: tour.polilynePoints,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    Map<String, Marker> poiMarkers = {};
    if (tour.pois.isNotEmpty) {
      for (var poi in tour.pois) {
        final icon = poi.imageUrl != null
            ? await getNetworkImageMarker(poi.imageUrl!)
            : await getCustomMarker();

        final poiMarker = Marker(
          markerId: MarkerId(poi.name),
          position: poi.gps,
          icon: icon,
          onTap: () async {
            if (state.mapContext != null) {
              log.i('Mostrando detalles del lugar: ${poi.name}');
              showPlaceDetails(state.mapContext!, poi);
            }
          },
        );
        poiMarkers[poi.name] = poiMarker;
      }
    }

    final currentPolylines = Map<String, Polyline>.from(state.polylines);

    // Añadir la polilínea del tour.
    currentPolylines['route'] = myRoute;

    // Incluir la polilínea del usuario si está activa.
    if (state.showUserRoute && state.polylines['myRoute'] != null) {
      currentPolylines['myRoute'] = state.polylines['myRoute']!;
    }

    final currentMarkers = Map<String, Marker>.from(state.markers);
    currentMarkers.addAll(poiMarkers);

    add(OnDisplayPolylinesEvent(currentPolylines, currentMarkers));

    if (tour.pois.isNotEmpty) {
      final LatLng firstPoiLocation = tour.pois.first.gps;
      log.i('Moviendo la cámara al primer POI: ${tour.pois.first.name}');
      await moveCamera(firstPoiLocation);
    }
  }

  /// Muestra los detalles de un punto de interés en un BottomSheet.
  void showPlaceDetails(BuildContext context, PointOfInterest poi) {
    log.i('Mostrando detalles del POI: ${poi.name}');
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomBottomSheet(poi: poi);
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }

  /// Elimina un marcador de punto de interés del mapa.
  void _onRemovePoiMarker(
      OnRemovePoiMarkerEvent event, Emitter<MapState> emit) {
    log.i('Eliminando marcador de POI: ${event.poiName}');
    final updatedMarkers = Map<String, Marker>.from(state.markers);
    updatedMarkers.remove(event.poiName);
    emit(state.copyWith(markers: updatedMarkers));
  }

  /// Añade un marcador de punto de interés al mapa.
  Future<void> _onAddPoiMarker(
      OnAddPoiMarkerEvent event, Emitter<MapState> emit) async {
    log.i('Añadiendo marcador de POI: ${event.poi.name}');
    final updatedMarkers = Map<String, Marker>.from(state.markers);
    final icon = event.poi.imageUrl != null
        ? await getNetworkImageMarker(event.poi.imageUrl!)
        : await getCustomMarker();

    final poiMarker = Marker(
      markerId: MarkerId(event.poi.name),
      position: event.poi.gps,
      icon: icon,
      onTap: () async {
        if (state.mapContext != null) {
          showPlaceDetails(state.mapContext!, event.poi);
        }
      },
    );

    updatedMarkers[event.poi.name] = poiMarker;
    emit(state.copyWith(markers: updatedMarkers));
  }

  /// Limpia todos los marcadores y polilíneas del mapa.
  void _onClearMap(OnClearMapEvent event, Emitter<MapState> emit) {
    log.i('MapBloc: Limpiando todos los marcadores y polilíneas del mapa.');
    emit(state.copyWith(
      polylines: {},
      markers: {},
    ));
  }

  @override
  Future<void> close() async {
    log.i('Cerrando MapBloc y cancelando suscripción de localización.');
    await locationSubscription?.cancel();
    await super.close();
  }
}
