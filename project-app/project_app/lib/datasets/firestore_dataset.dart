import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/logger/logger.dart';

class FirestoreDataset {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId;

  FirestoreDataset({required this.userId});

  Future<void> saveTour(EcoCityTour tour, String tourName) async {
    try {
      final tourData = {
        'userId': userId, // Guarda el userId en el tour
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
      final querySnapshot = await _firestore
          .collection('tours')
          .where('userId', isEqualTo: userId) // Filtra por el userId
          .get();
      log.i('Tours guardados recuperados: ${querySnapshot.docs.length} tours');

      return querySnapshot.docs.map((doc) {
        return EcoCityTour.fromFirestore(doc);
      }).toList();
    } catch (e) {
      log.e('Error al recuperar los tours guardados: $e');
      return [];
    }
  }

  Future<void> deleteTour(String tourName) async {
    try {
      log.d('Intentando eliminar el tour con nombre: $tourName');
      await _firestore.collection('tours').doc(tourName).delete();
      log.i('Tour eliminado con éxito: $tourName');
    } catch (e) {
      log.e('Error al eliminar el tour: $e');
    }
  }

  Future<DocumentSnapshot> getTourById(String documentId) async {
    return await _firestore.collection('tours').doc(documentId).get();
  }
}
