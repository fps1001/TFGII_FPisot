import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/ui/ui.dart';

class BtnCurrentLocation extends StatelessWidget {
  const BtnCurrentLocation({super.key});

  @override
  Widget build(BuildContext context) {
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);

    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        // Botón de centrado en la ubicación actual
        child: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor, 
            maxRadius: 25,
            child: IconButton(
                icon:
                    const Icon(Icons.my_location_outlined, color: Colors.white), // Icono blanco
                onPressed: () {
                  //Llamar al bloc
                  final userLocation = locationBloc.state.lastKnownLocation;
                                    
                  if (userLocation == null){
                    final SnackBar snackBar =
                      CustomSnackbar(msg: 'No hay ubicación');
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                  }
                  
                  mapBloc.moveCamera(userLocation);

                  
                })));
  }
}
