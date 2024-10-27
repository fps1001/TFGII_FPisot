import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/widgets/widgets.dart';

class SavedToursScreen extends StatelessWidget {
  final List<EcoCityTour> savedTours;

  const SavedToursScreen({super.key, required this.savedTours});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus Eco City Tours Guardados'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: savedTours.isEmpty
          ? const Center(child: Text('No tienes tours guardados'))
          : ListView.builder(
              itemCount: savedTours.length,
              itemBuilder: (context, index) {
                final tour = savedTours[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      tour.city,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Distancia: ${tour.distance?.toStringAsFixed(2) ?? "N/A"} km'),
                        Text('Duración: ${tour.duration != null ? "${tour.duration!.toInt()} min" : "N/A"}'),
                        Text('Preferencias: ${tour.userPreferences.join(", ")}'),
                        const SizedBox(height: 8),
                      ],
                    ),
                    leading: Icon(
                      tour.mode == 'walking' ? Icons.directions_walk : Icons.directions_bike,
                      color: Theme.of(context).primaryColor,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navega al mapa con el tour seleccionado
                      context.push('/map', extra: tour);
                    },
                  ),
                );
              },
            ),
    );
  }
}
