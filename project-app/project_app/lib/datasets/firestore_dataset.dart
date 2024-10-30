import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger

class FirestoreDataset {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveTour(EcoCityTour tour, String tourName) async {
    try {
      final tourData = {
        'city': tour.city,
        'mode': tour.mode,
        'userPreferences': tour.userPreferences,
        'duration': tour.duration,
        'distance': tour.distance,
        'polilynePoints': tour.polilynePoints
            .map((point) => {'lat': point.latitude, 'lng': point.longitude})
            .toList(),
        'pois': tour.pois
            .map((poi) => {
                  'name': poi.name,
                  'gps': {'lat': poi.gps.latitude, 'lng': poi.gps.longitude},
                  'description': poi.description,
                  'url': poi.url,
                  'imageUrl': poi.imageUrl,
                  'rating': poi.rating,
                  'address': poi.address,
                  'userRatingsTotal': poi.userRatingsTotal,
                })
            .toList(),
      };

      log.d('Intentando guardar el tour con nombre: $tourName');
      await _firestore.collection('tours').doc(tourName).set(tourData);
      log.i('Tour guardado con éxito: $tourName');
    } catch (e) {
      log.e('Error al guardar el tour: $e');
    }
  }

  Future<List<EcoCityTour>> getSavedTours() async {
    try {
      final querySnapshot = await _firestore.collection('tours').get();
      log.i(
          'Tours guardados recuperados con éxito: ${querySnapshot.docs.length} tours');

      return querySnapshot.docs.map((doc) {
        return EcoCityTour.fromFirestore(
            doc); // Ahora usamos el constructor que asigna documentId
      }).toList();
    } catch (e) {
      log.e('Error al recuperar los tours guardados: $e');
      return [];
    }
  }

  Future<void> deleteTour(String tourName) async {
    try {
      log.d(
          'Intentando eliminar el documento en Firestore con el nombre: $tourName');
      await _firestore.collection('tours').doc(tourName).delete();
      log.i('Tour eliminado con éxito: $tourName');
    } catch (e) {
      log.e('Error al eliminar el tour en Firestore: $e');
    }
  }
}
