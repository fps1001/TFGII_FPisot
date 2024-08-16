import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/blocs/blocs.dart';

import 'package:project_app/views/views.dart';
import 'package:project_app/widgets/widgets.dart';

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
        builder: (context, locationState) {
          // Si llega a este punto la ubicación es conocida (null-safety)
          if (locationState.lastKnownLocation == null) {
            return const Center(
              child: Text('Espere por favor...'),
            );
          }

          return BlocBuilder<MapBloc, MapState>(
            builder: (context, mapState) {
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    MapView(
                      initialPosition: locationState.lastKnownLocation!,
                      polylines: mapState.polylines.values.toSet(),
                    ),
                  ],
                  //TODO: Botones...
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BtnFollowUser(),
          BtnCurrentLocation(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    locationBloc.stopFollowingUser();
    super.dispose();
  }
}
