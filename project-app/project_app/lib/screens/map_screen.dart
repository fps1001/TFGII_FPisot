import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/views/views.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LocationBloc locationBloc;

  @override
  void initState() {
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
    locationBloc.startFollowingUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state.lastKnownLocation == null) {
            return const Center(
              child: Text('Espere por favor...'),
            );
          }
          const CameraPosition initialCameraPosition = CameraPosition(
              bearing: 192.8334901395799,
              // TODO target debería ser el state.lastKnownLocation!
              target: LatLng(37.43296265331129, -122.08832357078792),
              zoom: 15);

          return const GoogleMap(initialCameraPosition: initialCameraPosition);
        },
      ),
    );
  }

  @override
  void dispose() {
    locationBloc.stopFollowingUser();
    super.dispose();
  }
}
