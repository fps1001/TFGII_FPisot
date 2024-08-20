// ignore_for_file: prefer_const_constructors

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:project_app/blocs/blocs.dart';

class ManualMarker extends StatelessWidget {
  const ManualMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        // Si debe mostrar el marcador lo indicará la variable del bloc
        return state.displayManualMarker
            ? const _ManualMarkerBody()
            // Sizebox vacío por eficiencia en vez de contenedor (no puede ser constante).
            : SizedBox();
      },
    );
  }
}

class _ManualMarkerBody extends StatelessWidget {
  const _ManualMarkerBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: 150,
      // Widget de animación de caida de marcador.
      child: Stack(
        children: [
          const Positioned(
            top: 70,
            left: 20,
            child: _Btn_back(),
          ),
          Center(
            // Va a centrar el marcador en la pantalla con el widget transform.
            child: Transform.translate(
              offset: Offset(0, -22),
              child: BounceInDown(
                from: 100,
                child: const Icon(Icons.location_on_rounded, size: 60),
              ),
            ),
          ),

          // Boton de confirmar
          Positioned(
              bottom: 70,
              left: 40,
              child: FadeInUp(
                duration: const Duration(milliseconds: 300),
                child: MaterialButton(
                  minWidth: size.width - 120,
                  color: Colors.black,
                  elevation: 0,
                  height: 50,
                  // Bordes redondeados
                  shape: const StadiumBorder(),
                  onPressed: () {
                    // TODO confirmar ubicación.
                  },
                  child: const Text(
                    'Confirmar destino',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w300),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

class _Btn_back extends StatelessWidget {
  const _Btn_back();

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 300),
      child: CircleAvatar(
        maxRadius: 30,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () {
            // TODO Cancelar el marcador manual
          },
        ),
      ),
    );
  }
}
