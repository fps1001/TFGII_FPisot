import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:project_app/blocs/blocs.dart';

class GpsAccessScreen extends StatelessWidget {
  const GpsAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<GpsBloc, GpsState>(
        listener: (context, state) {
          if (state.isGpsEnabled) {
            // Si el GPS está habilitado, navegamos a la siguiente pantalla
            context.go(
                '/tour-selection'); // Cambia la ruta a la pantalla de selección de tour
          }
        },
        child: Center(
          child: BlocBuilder<GpsBloc, GpsState>(
            builder: (context, state) {
              if (state.isGpsEnabled) {
                return const _AccessButton();
              } else {
                return const _EnableGpsMessage();
              }
            },
          ),
        ),
      ),
    );
  }
}

class _AccessButton extends StatelessWidget {
  const _AccessButton();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Es necesario habilitar el GPS para continuar',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                color: Theme.of(context).primaryColor, // Color del tema
              ), // Aplicar el estilo del tema
        ),
        const SizedBox(height: 20), // Espacio entre el texto y el botón
        MaterialButton(
          minWidth: MediaQuery.of(context).size.width -
              120, // Ancho como el botón de "Confirmar destino"
          color: Theme.of(context).primaryColor, // Color de fondo del tema
          elevation: 0,
          height: 50,
          shape: const StadiumBorder(), // Bordes redondeados
          onPressed: () {
            final gpsBloc = BlocProvider.of<GpsBloc>(context);
            gpsBloc.askGpsAccess(); // Solicitamos acceso al GPS
          },
          child: const Text(
            'Solicitar acceso al GPS',
            style: TextStyle(
              color: Colors.white, // Texto en blanco
              fontWeight: FontWeight.w600, // Peso del texto
            ),
          ),
        ),
      ],
    );
  }
}

class _EnableGpsMessage extends StatelessWidget {
  const _EnableGpsMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Debe habilitar el GPS para continuar',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).primaryColor,
          ),
    );
  }
}
