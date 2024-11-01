import 'package:flutter/material.dart';
import 'package:project_app/helpers/helpers.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:project_app/screens/screens.dart';

class SavedToursScreen extends StatelessWidget {
  const SavedToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus Eco City Tours Guardados'),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/tour-selection');
          },
        ),
      ),
      body: BlocBuilder<TourBloc, TourState>(
        builder: (context, state) {
          final savedTours = state.savedTours;

          if (savedTours.isEmpty) {
            return _buildEmptyState(context); // Mostrar estado vacío cuando no hay tours
          }

          return ListView.builder(
            itemCount: savedTours.length,
            itemBuilder: (context, index) {
              final tour = savedTours[index];
              final tourName = '${tour.documentId ?? 'Tour'} - ${tour.city}';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    tourName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                    onPressed: () => _deleteTour(context, tour.documentId),
                  ),
                  onTap: () {
                    log.d('Usuario seleccionó el tour: ${tour.documentId}');
                    BlocProvider.of<TourBloc>(context).add(
                      LoadTourFromSavedEvent(documentId: tour.documentId!),
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: BlocProvider.of<TourBloc>(context),
                          child: MapScreen(tour: tour),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline,
                size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            Text(
              'No tienes tours guardados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Explora y guarda tus Eco City Tours favoritos para acceder a ellos aquí.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text(
                'Explorar Tours',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                context.go('/tour-selection');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTour(BuildContext context, String? documentId) async {
    if (documentId == null) {
      log.e('No se puede eliminar el tour: documentId es null');
      return;
    }

    final tourBloc = BlocProvider.of<TourBloc>(context);
    log.d('Usuario intentó eliminar el tour con documentId: $documentId');

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
        log.i('Intentando eliminar el tour con documentId: $documentId');
        await tourBloc.ecoCityTourRepository.deleteTour(documentId);
        log.i('Tour eliminado exitosamente con documentId: $documentId');

        // Recargar la lista de tours guardados después de eliminar
        tourBloc.add(const LoadSavedToursEvent());
      } catch (e) {
        log.e('Error al eliminar el tour con documentId $documentId: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar el tour')),
          );
        }
      }
    }
  }
}
