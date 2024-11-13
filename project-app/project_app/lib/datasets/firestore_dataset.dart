import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/logger/logger.dart';

class FirestoreDataset {
  final FirebaseFirestore firestore;
  final String? userId;

  // Constructor que permite inyectar una instancia de FirebaseFirestore
  FirestoreDataset({
    required this.userId,
    FirebaseFirestore? firestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveTour(EcoCityTour tour, String tourName) async {
    try {
      final tourData = {
        'userId': userId,
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
      await firestore.collection('tours').doc(tourName).set(tourData);
      log.i('Tour guardado con éxito: $tourName');
    } catch (e) {
      log.e('Error al guardar el tour: $e');
    }
  }

  Future<List<EcoCityTour>> getSavedTours() async {
    try {
      final querySnapshot = await firestore
          .collection('tours')
          .where('userId', isEqualTo: userId)
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
      await firestore.collection('tours').doc(tourName).delete();
      log.i('Tour eliminado con éxito: $tourName');
    } catch (e) {
      log.e('Error al eliminar el tour: $e');
    }
  }

  Future<DocumentSnapshot> getTourById(String documentId) async {
    return await firestore.collection('tours').doc(documentId).get();
  }
}
