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

class MapBloc extends Bloc<MapEvent, MapState> {
  GoogleMapController? _mapController;
  final LocationBloc locationBloc;
  StreamSubscription<LocationState>? locationSubscription;

  LatLng? mapCenter;

  MapBloc({required this.locationBloc}) : super(const MapState()) {
    on<OnMapInitializedEvent>(_onInitMap);
    on<OnStartFollowingUserEvent>(_onStartFollowingUser);
    on<OnStopFollowingUserEvent>(
        (event, emit) => emit(state.copyWith(isFollowingUser: false)));
    on<OnUpdateUserPolylinesEvent>(_onPolylineNewPoint);
    on<OnDisplayPolylinesEvent>((event, emit) => emit(
        state.copyWith(polylines: event.polylines, markers: event.markers)));
    on<OnToggleShowUserRouteEvent>((event, emit) =>
        emit(state.copyWith(showUserRoute: !state.showUserRoute)));
    on<OnRemovePoiMarkerEvent>(_onRemovePoiMarker);
    on<OnAddPoiMarkerEvent>(_onAddPoiMarker);
    // Añadir el manejador de evento en el constructor del MapBloc
    on<OnClearMapEvent>(_onClearMap);

    locationSubscription = locationBloc.stream.listen((locationState) {
      if (locationState.lastKnownLocation != null) {
        log.i(
            'Añadiendo nueva polilínea con la ubicación del usuario: ${locationState.lastKnownLocation}');
        add(OnUpdateUserPolylinesEvent(locationState.myLocationHistory));
      }

      if (!state.isFollowingUser) return;
      if (locationState.lastKnownLocation == null) return;

      //moveCamera(locationState.lastKnownLocation!);
    });
  }

  void _onInitMap(OnMapInitializedEvent event, Emitter<MapState> emit) {
    _mapController = event.mapController;
    log.i('Mapa inicializado. Controlador del mapa establecido.');
    emit(state.copyWith(isMapInitialized: true, mapContext: event.mapContext));
  }

  void moveCamera(LatLng latLng) {
    if (_mapController == null) {
      log.w('El controlador del mapa aún no está listo.');
      return;
    }
    log.i('Moviendo cámara a la posición: $latLng');
    final cameraUpdate = CameraUpdate.newLatLng(latLng);
    _mapController?.animateCamera(cameraUpdate);
  }

  void _onStartFollowingUser(
      OnStartFollowingUserEvent event, Emitter<MapState> emit) {
    emit(state.copyWith(isFollowingUser: true));
    log.i('Comenzando a seguir al usuario.');
    if (locationBloc.state.lastKnownLocation == null) return;
    moveCamera(locationBloc.state.lastKnownLocation!);
  }

  void _onPolylineNewPoint(
      OnUpdateUserPolylinesEvent event, Emitter<MapState> emit) {
    log.i('Añadiendo nuevo punto a la polilínea.');
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

  Future<void> drawEcoCityTour(EcoCityTour tour) async {
    log.i('Dibujando EcoCityTour en el mapa: ${tour.name}');
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
    final currentMarkers = Map<String, Marker>.from(state.markers);
    currentPolylines['route'] = myRoute;
    currentMarkers.addAll(poiMarkers);

    // Mandar a mostrar las polilíneas y marcadores
    add(OnDisplayPolylinesEvent(currentPolylines, currentMarkers));

    // Centramos la cámara en el primer POI del tour
    if (tour.pois.isNotEmpty) {
      final LatLng firstPoiLocation = tour.pois.first.gps;
      log.i('Moviendo la cámara al primer POI: ${tour.pois.first.name}');
      moveCamera(firstPoiLocation);
    }
  }

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

  void _onRemovePoiMarker(
      OnRemovePoiMarkerEvent event, Emitter<MapState> emit) {
    log.i('Eliminando marcador de POI: ${event.poiName}');
    final updatedMarkers = Map<String, Marker>.from(state.markers);
    updatedMarkers.remove(event.poiName);
    emit(state.copyWith(markers: updatedMarkers));
  }

  void _onAddPoiMarker(
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

// Modificar el MapBloc para manejar el evento de limpiar el mapa
  void _onClearMap(OnClearMapEvent event, Emitter<MapState> emit) {
    log.i('MapBloc: Limpiando todos los marcadores y polilíneas del mapa.');
    emit(state.copyWith(
      polylines: {}, // Limpiamos todas las polilíneas
      markers: {}, // Limpiamos todos los marcadores
    ));
  }

  @override
  Future<void> close() {
    log.i('Cerrando MapBloc y cancelando suscripción de localización.');
    locationSubscription?.cancel();
    return super.close();
  }
}
