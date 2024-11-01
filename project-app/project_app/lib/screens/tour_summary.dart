import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/helpers/helpers.dart'; // Importar el archivo de helpers
import 'package:project_app/ui/ui.dart';
import 'package:project_app/widgets/widgets.dart';
import 'package:project_app/blocs/blocs.dart';

class TourSummary extends StatelessWidget {
  const TourSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;

    return BlocBuilder<TourBloc, TourState>(
      builder: (context, state) {
        if (state.ecoCityTour == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CustomSnackbar.show(
                context, 'Eco City Tour vacío, genera uno nuevo');
            Navigator.pop(context);
          });
          return const SizedBox.shrink();
        }

        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            title: const Text(
              'Resumen de tu Eco City Tour',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.save_as_rounded),
                tooltip: 'Guardar Eco City Tour',
                onPressed: () async {
                  final tourName = await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      String inputText = '';
                      return AlertDialog(
                        title: const Text('Nombre del Tour'),
                        content: TextField(
                          onChanged: (value) => inputText = value,
                          decoration: const InputDecoration(
                              hintText: "Escribe un nombre"),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, inputText),
                            child: const Text('Guardar'),
                          ),
                        ],
                      );
                    },
                  );
                  if (tourName != null && tourName.isNotEmpty && context.mounted) {
                    await BlocProvider.of<TourBloc>(context)
                        .saveCurrentTour(tourName);
                    if (context.mounted) {
                      CustomSnackbar.show(
                          context, 'Ruta guardada exitosamente');
                    }
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Center(
                  child: SizedBox(
                    width: cardWidth,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ciudad: ${state.ecoCityTour!.city}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Distancia: ${formatDistance(state.ecoCityTour!.distance ?? 0)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Duración: ${formatDuration((state.ecoCityTour!.duration ?? 0).toInt())}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text('Medio de transporte:',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Icon(
                                  transportIcons[state.ecoCityTour!.mode],
                                  size: 24,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.ecoCityTour!.pois.length,
                  itemBuilder: (context, index) {
                    final poi = state.ecoCityTour!.pois[index];
                    return ExpandablePoiItem(
                        poi: poi, tourBloc: BlocProvider.of<TourBloc>(context));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
