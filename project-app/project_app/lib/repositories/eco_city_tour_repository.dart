import 'package:project_app/datasets/firestore_dataset.dart';
import 'package:project_app/models/models.dart';

class EcoCityTourRepository {
  final FirestoreDataset _dataset;

  EcoCityTourRepository(this._dataset);

  Future<void> saveTour(EcoCityTour tour, String tourName) {
    return _dataset.saveTour(tour, tourName);
  }

  Future<List<EcoCityTour>> getSavedTours() {
    return _dataset.getSavedTours();
  }
}
