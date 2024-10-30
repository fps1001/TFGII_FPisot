import 'package:project_app/datasets/firestore_dataset.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/logger/logger.dart';

class EcoCityTourRepository {
  final FirestoreDataset _dataset;

  EcoCityTourRepository(this._dataset);

  Future<void> saveTour(EcoCityTour tour, String tourName) async {
    log.d('Intentando guardar el tour: $tourName');
    await _dataset.saveTour(tour, tourName);
  }

  Future<List<EcoCityTour>> getSavedTours() async {
    log.d('Intentando recuperar los tours guardados');
    return await _dataset.getSavedTours();
  }

  Future<void> deleteTour(String tourName) async {
    log.d('Intentando eliminar el tour: $tourName');
    await _dataset.deleteTour(tourName);
  }

Future<EcoCityTour?> getTourById(String documentId) async {
  try {
    final docSnapshot = await _dataset.getTourById(documentId);
    if (docSnapshot.exists) {
      return EcoCityTour.fromFirestore(docSnapshot);
    }
    log.w('El documento con ID $documentId no existe en Firestore.');
    return null;
  } catch (e) {
    log.e('Error al obtener el tour con ID $documentId: $e');
    return null;
  }
}


}
