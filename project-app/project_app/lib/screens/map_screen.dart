import 'package:flutter/material.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/views/views.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LocationBloc locationBloc; //late para dejarlo sin inicializarlo.

  @override
  void initState() {
    super.initState();

    locationBloc =
        BlocProvider.of<LocationBloc>(context); // Se instancia -> late.
    //locationBloc.getCurrentPosition();
    locationBloc.startFollowingUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        if (state.lastKnownLocation == null) {
          return const Center(
            child: Text('Espere por favor...'),
          );
        }
        return Center(
          child: Text(
              '${state.lastKnownLocation!.latitude}, ${state.lastKnownLocation!.longitude}'),
        );
      },
    ));
  }

  @override
  void dispose() {
    locationBloc.stopFollowingUser(); // No repito definición de locationBloc
    super.dispose();
  }
}
