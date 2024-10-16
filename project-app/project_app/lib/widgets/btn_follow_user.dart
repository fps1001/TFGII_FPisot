import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/blocs/blocs.dart';


class BtnFollowUser extends StatelessWidget {
  const BtnFollowUser({super.key});

  @override
  Widget build(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context);

    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        // Botón de centrado en la ubicación actual
        child: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor, 
            maxRadius: 25,
            // BlocBuilder para saber si se sigue al usuario.
            child: BlocBuilder<MapBloc, MapState>(
              builder: (context, state) {
                return IconButton(
                    icon:  Icon( state.isFollowingUser ? Icons.directions_run_outlined : Icons.my_location_outlined,
                        color: Colors.white),
                    onPressed: () {
                      mapBloc.add(OnStartFollowingUserEvent());
                      }  
                    );
              },
            )));
  }
}
