import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/models/models.dart';

class FirestoreDataset {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveTour(EcoCityTour tour, String tourName) async {
    final tourData = {
      'city': tour.city,
      'mode': tour.mode,
      'userPreferences': tour.userPreferences,
      'duration': tour.duration,
      'distance': tour.distance,
      'polilynePoints': tour.polilynePoints
          .map((point) => {'lat': point.latitude, 'lng': point.longitude})
          .toList(),
      'pois': tour.pois.map((poi) => {
            'name': poi.name,
            'gps': {'lat': poi.gps.latitude, 'lng': poi.gps.longitude},
            'description': poi.description,
            'url': poi.url,
            'imageUrl': poi.imageUrl,
            'rating': poi.rating,
            'address': poi.address,
            'userRatingsTotal': poi.userRatingsTotal,
          }).toList(),
    };

    await _firestore.collection('tours').doc(tourName).set(tourData);
  }

  Future<List<EcoCityTour>> getSavedTours() async {
    final querySnapshot = await _firestore.collection('tours').get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return EcoCityTour(
        city: data['city'],
        mode: data['mode'],
        userPreferences: List<String>.from(data['userPreferences']),
        duration: (data['duration'] as num?)?.toDouble(),
        distance: (data['distance'] as num?)?.toDouble(),
        polilynePoints: (data['polilynePoints'] as List)
            .map((point) => LatLng(point['lat'], point['lng']))
            .toList(),
        pois: (data['pois'] as List).map((poiData) {
          final poiGps = poiData['gps'];
          return PointOfInterest(
            gps: LatLng(poiGps['lat'], poiGps['lng']),
            name: poiData['name'],
            description: poiData['description'],
            url: poiData['url'],
            imageUrl: poiData['imageUrl'],
            rating: (poiData['rating'] as num?)?.toDouble(),
            address: poiData['address'],
            userRatingsTotal: poiData['userRatingsTotal'],
          );
        }).toList(),
      );
    }).toList();
  }
}
