import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:project_app/blocs/blocs.dart';

class GpsAccessScreen extends StatelessWidget {
  const GpsAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<GpsBloc, GpsState>(builder: (context, state) {
          if (state.isGpsEnabled) {
            return const _EnableGpsMessage();
          } else {
            return const _AccessButton();
          }
        }),
        //_AccessButton(), // Será uno u otro en función del GPS activado o no
        //child: _EnableGpsMessage(),
      ),
    );
  }
}

class _AccessButton extends StatelessWidget {
  const _AccessButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [const Text('Es necesario habilitar el GPS para continuar'),
      MaterialButton(
        child: const Text('Solicitar acceso al GPS'),
        onPressed: (){
        //TODO: Implementar la navegación a la pantalla de configuración de GPS
      }),
    ],
      
    );
  }
}

class _EnableGpsMessage extends StatelessWidget {
  const _EnableGpsMessage();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Debe habilitar el GPS para continuar',
      style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

