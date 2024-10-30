import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/helpers/helpers.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavedToursScreen extends StatelessWidget {
  final List<EcoCityTour> savedTours;

  const SavedToursScreen({super.key, required this.savedTours});

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus Eco City Tours Guardados'),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: savedTours.isEmpty
          ? const Center(child: Text('No tienes tours guardados'))
          : ListView.builder(
              itemCount: savedTours.length,
              itemBuilder: (context, index) {
                final tour = savedTours[index];
                
                final tourName = '${tour.name} - ${tour.city}';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      tourName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Distancia: ${formatDistance(tour.distance ?? 0)}'),
                        Text('Duración: ${formatDuration((tour.duration ?? 0).toInt())}'),
                        const SizedBox(height: 4),
                        Row(
                          children: tour.userPreferences.map((preference) {
                            final prefIconData = userPreferences[preference];
                            if (prefIconData != null) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  prefIconData['icon'],
                                  color: prefIconData['color'],
                                  size: 24,
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    leading: Icon(
                      transportIcons[tour.mode] ?? Icons.directions_walk,
                      color: Theme.of(context).primaryColor,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTour(context, tour.name),
                    ),
                    onTap: () {
                      log.d('Usuario seleccionó el tour: $tourName');
                      context.pushNamed('map', extra: tour.toJson());
                    },
                  ),
                );
              },
            ),
    );
  }
}
void _deleteTour(BuildContext context, String tourName) async {
  final tourBloc = BlocProvider.of<TourBloc>(context);
  
  log.d('Usuario intentó eliminar el tour: $tourName');

  // Pedir confirmación antes de borrar
  final confirmDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Eliminar Tour'),
        content: const Text('¿Estás seguro de que deseas eliminar este tour?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );

  if (confirmDelete == true) {
    try {
      log.i('Intentando eliminar el tour con nombre: $tourName');
      await tourBloc.ecoCityTourRepository.deleteTour(tourName);
      log.i('Tour eliminado exitosamente: $tourName');
      
      // Mostrar notificación de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tour eliminado correctamente')),
      );

      // Recargar la lista de tours después de eliminar
      tourBloc.add(const LoadSavedToursEvent());
    } catch (e) {
      log.e('Error al eliminar el tour $tourName: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el tour')),
      );
    }
  }
}
