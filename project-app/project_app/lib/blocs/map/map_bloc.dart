import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/helpers/custom_image_marker.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/services.dart';

import '../../widgets/widgets.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  // Opcional porque al iniciar no existe.
  GoogleMapController? _mapController;
  // Añado bloc de localización
  final LocationBloc locationBloc;
  StreamSubscription<LocationState>? locationSubscription;

  LatLng? mapCenter;
  // Instancia del servicio de Places
  final PlacesService _placesService = PlacesService(); 

  MapBloc({required this.locationBloc}) : super(const MapState()) {
    // Cuando recibo un evento de tipo OnMapInitializedEvent emite un nuevo estado.
    on<OnMapInitializedEvent>(_onInitMap);
    // Cuando recibo un evento de tipo OnStartFollowingUserEvent emite un nuevo estado.
    on<OnStartFollowingUserEvent>(_onStartFollowingUser);
    // Cuando recibo un evento de tipo OnStopFollowingUserEvent emite un nuevo estado.
    on<OnStopFollowingUserEvent>(
        (event, emit) => emit(state.copyWith(isFollowingUser: false)));
    // Cuando recibo un evento de tipo OnUpdateUserPolylinesEvent emite un nuevo estado.
    on<OnUpdateUserPolylinesEvent>(_onPolylineNewPoint);
    // Cuando recibo una nueva polilínea a dibujar emite un nuevo estado al que le pasa la nueva polilínea.
    on<OnDisplayPolylinesEvent>((event, emit) => emit(
        state.copyWith(polylines: event.polylines, markers: event.markers)));

    // Cuando recibo un evento de tipo OnToggleShowUserRouteEvent emite un nuevo estado.
    on<OnToggleShowUserRouteEvent>((event, emit) =>
        emit(state.copyWith(showUserRoute: !state.showUserRoute)));

    // Suscripción al bloc de localización.
    locationSubscription = locationBloc.stream.listen((locationState) {
      // Llama al evento de añadir una polilínea al recorrido de usuario.
      if (locationState.lastKnownLocation != null) {
        add(OnUpdateUserPolylinesEvent(locationState.myLocationHistory));
      }

      // Saber si hay que mover la cámara.
      if (!state.isFollowingUser) return;
      if (locationState.lastKnownLocation == null) return;

      moveCamera(locationState.lastKnownLocation!);
    });
  }

  void _onInitMap(OnMapInitializedEvent event, Emitter<MapState> emit) {
    {
      _mapController = event.mapController;
      // Copio también el contexto del mapa para poder interactuar con la UI.
      emit(state.copyWith(
          isMapInitialized: true,
          mapContext: event.mapContext)); // Se guarda el BuildContext
    }
  }

  void moveCamera(LatLng latLng) {
    final cameraUpdate = CameraUpdate.newLatLng(latLng);
    _mapController?.animateCamera(cameraUpdate);
  }

  //Función para que al tocar el botón se centre en el usuario sin esperar al cambio de localización.
  void _onStartFollowingUser(
      OnStartFollowingUserEvent event, Emitter<MapState> emit) {
    emit(state.copyWith(isFollowingUser: true));
    if (locationBloc.state.lastKnownLocation == null) return;
    moveCamera(locationBloc.state.lastKnownLocation!);
  }

  // Función para añadir un punto a una polilínea.
  void _onPolylineNewPoint(
      OnUpdateUserPolylinesEvent event, Emitter<MapState> emit) {
    // Se crea la nueva polilínea y se añade a las que ya había.
    final myRoute = Polyline(
      polylineId: const PolylineId('myRoute'),
      points: event.userLocations,
      width: 5,
      color: const Color.fromARGB(255, 207, 18, 135),
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    // crea una copia del estado actual y se añade la nueva polilínea.
    currentPolylines['myRoute'] = myRoute;
    // Emite el nuevo estado.
    emit(state.copyWith(polylines: currentPolylines));
  }

  // Metodo que recibe una polilínea y la emite en un nuevo evento.
  // Ahora con POI's opcionales.
  Future<void> drawRoutePolyline(RouteDestination destination,
      [List<PointOfInterest>? pois]) async {
    final myRoute = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.teal,
      width: 5,
      points: destination.points,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    double kms = destination.distance / 1000;
    kms = (kms * 100).floorToDouble();
    kms /= 100;

    double tripDuration = (destination.duration / 60).floorToDouble();

    //final startMarkerIcon = await getCustomMarker();
    //final defaultIcon = await getCustomMarker();
/* 
    final startMarker = Marker(
      markerId: const MarkerId('start'),
      position: destination.points.first,
      icon: startMarkerIcon,
      infoWindow: InfoWindow(
        title: 'Inicio',
        snippet: 'Kms: $kms, duración: $tripDuration',
      ),
    );

    final finalMarker = Marker(
      markerId: const MarkerId('final'),
      position: destination.points.last,
      icon: defaultIcon,
      infoWindow: InfoWindow(
        title: destination.endPlace.text,
        snippet: destination.endPlace.placeName,
      ),
    ); */

    // Marcadores de puntos de interés

    Map<String, Marker> poiMarkers = {};
    if (pois != null) {
      for (var poi in pois) {
        final icon = poi.imageUrl != null
            ? await getNetworkImageMarker(poi.imageUrl!)
            : await getCustomMarker();

        final poiMarker = Marker(
          markerId: MarkerId(poi.name),
          position: poi.gps,
          icon: icon,
          onTap: () async {
            if (state.mapContext != null) {
              // Hacer la búsqueda de detalles del lugar
              final placeJson = await _placesService.searchPlace(poi.name);
              if (placeJson != null) {
                final place = Place.fromJson(placeJson); // Crea un objeto Place desde el JSON
                showPlaceDetails(state.mapContext!, place); // Llama a la función para mostrar el BottomSheet
              } else {
                if (kDebugMode) {
                  print('No se encontraron resultados para el lugar: ${poi.name}');
                }
              }
            }
          },
        );
        poiMarkers[poi.name] = poiMarker;
      }
    }

    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    final currentMarkers = Map<String, Marker>.from(state.markers);

    currentPolylines['route'] = myRoute;
   // currentMarkers['start'] = startMarker;
    //currentMarkers['final'] = finalMarker;

    // Agregar los marcadores de POIs
    currentMarkers.addAll(poiMarkers);

    add(OnDisplayPolylinesEvent(currentPolylines, currentMarkers));

  }

   // Función para mostrar el `BottomSheet` con los detalles del lugar
  void showPlaceDetails(BuildContext context, Place place) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return CustomBottomSheet(place: place); // Pasa el objeto `Place` directamente
    },
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
  );
}

  @override
  Future<void> close() {
    locationSubscription?.cancel();
    return super.close();
  }
}
