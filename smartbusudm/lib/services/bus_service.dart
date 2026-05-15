import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartbusudm/models/bus_model.dart';

class BusService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addBus(Bus bus) async {
    try {
      await _db.collection('buses').doc(bus.id).set(bus.toMap());
    } catch (e) {
      throw Exception("Erreur ajout bus: $e");
    }
  }
}