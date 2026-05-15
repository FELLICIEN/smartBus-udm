

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/station_model.dart';

class StationService {
  final CollectionReference stationRef =
      FirebaseFirestore.instance.collection('stations');

  Future<void> addStation(Station station) async {
    await stationRef.doc(station.id).set(station.toMap());
  }

  Stream<List<Station>> getStations() {
    return stationRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) =>
            Station.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Future<void> deleteStation(String id) async {
    await stationRef.doc(id).delete();
  }
}