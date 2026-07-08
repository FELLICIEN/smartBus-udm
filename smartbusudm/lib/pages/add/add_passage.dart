import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:smartbusudm/models/passage_model.dart';

class AddPassagePage extends StatefulWidget {
  const AddPassagePage({super.key});

  @override
  State<AddPassagePage> createState() => _AddPassagePageState();
}

class _AddPassagePageState extends State<AddPassagePage> {
  String? selectedBus;
  String? selectedStation;
  DateTime? selectedDateTime;

  bool loading = false;
  String error = "";

  String? chauffeurId;
  String? chauffeurNom;

  /// 🔥 GET CHAUFFEUR INFOS
  Future<void> getChauffeurInfos(String busId) async {
    final busDoc = await FirebaseFirestore.instance
        .collection('buses')
        .doc(busId)
        .get();

    final data = busDoc.data();

    if (data != null) {
      setState(() {
        chauffeurId = data['chauffeurId'];
        chauffeurNom = data['chauffeur'] ?? "Non défini";
      });
    }
  }

  /// 🚌 BUSES STREAM
  Stream<List<Map<String, dynamic>>> getBuses() {
    return FirebaseFirestore.instance.collection('buses').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'nom': doc['nom'],
          };
        }).toList();
      },
    );
  }

  /// 📍 STATIONS STREAM
  Stream<List<Map<String, dynamic>>> getStations() {
    return FirebaseFirestore.instance.collection('stations').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'nom': doc['nom'],
          };
        }).toList();
      },
    );
  }

  /// 🕒 PICK TIME
  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final now = DateTime.now();

      setState(() {
        selectedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  /// 💾 SAVE PASSAGE
  Future<void> savePassage() async {
    if (selectedBus == null ||
        selectedStation == null ||
        selectedDateTime == null) {
      setState(() {
        error = "Veuillez remplir tous les champs";
      });
      return;
    }

    setState(() {
      loading = true;
      error = "";
    });

    try {
      final busDoc = await FirebaseFirestore.instance
          .collection("buses")
          .doc(selectedBus)
          .get();

      final busNom = busDoc.data()?['nom'] ?? "Bus inconnu";

      final stationDoc = await FirebaseFirestore.instance
          .collection("stations")
          .doc(selectedStation)
          .get();

      final stationNom = stationDoc.data()?['nom'] ?? "Station inconnue";

      final passage = Passage(
  id: const Uuid().v4(),

  busId: selectedBus!,
  busNom: busNom ?? '',

  chauffeurId: chauffeurId ?? '',
  chauffeurNom: chauffeurNom ?? '',

  stationId: selectedStation!,
  userId: '',

  heurePrevue: selectedDateTime!,
  retard: 0,
  status: 'a_l_heure',
);

      await FirebaseFirestore.instance
          .collection('passages')
          .doc(passage.id)
          .set({
        ...passage.toMap(),
        "busNom": busNom,
        "stationNom": stationNom,
        "chauffeurNom": chauffeurNom,
        "chauffeurId": chauffeurId,
        "createdAt": Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passage programmé avec succès ✅"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  /// 🎨 STYLE INPUT
  InputDecoration style(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          "Programmer un Passage",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  SizedBox(height: 20),
                  Icon(Icons.route, size: 70, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Planification de trajet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// 🚌 BUS
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: getBuses(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final buses = snapshot.data!;

                      return DropdownButtonFormField<String>(
  initialValue: selectedBus,
  isExpanded: true,
  decoration: style("Bus", Icons.directions_bus),
  items: buses.map((bus) {
    return DropdownMenuItem<String>(
      value: bus['id'],
      child: Text(bus['nom']),
    );
  }).toList(),
  onChanged: (value) async {
    setState(() {
      selectedBus = value;
      selectedStation = null;
      chauffeurId = null;
      chauffeurNom = null;
    });

    if (value != null) {
      await getChauffeurInfos(value);
    }
  },
);
                    },
                  ),

                  const SizedBox(height: 18),

                  /// 📍 STATION
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: getStations(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final stations = snapshot.data!;

                    return DropdownButtonFormField<String>(
  initialValue: selectedStation,
  isExpanded: true,
  decoration: style("Station", Icons.location_on),
  items: stations.map((station) {
    return DropdownMenuItem<String>(
      value: station['id'],
      child: Text(station['nom']),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedStation = value;
    });
  },
);
                    },
                  ),

                  const SizedBox(height: 18),

                  /// 🕒 TIME
                  InkWell(
                    onTap: pickTime,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(
                            selectedDateTime == null
                                ? "Choisir l'heure"
                                : DateFormat("HH:mm").format(selectedDateTime!),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        error,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  /// 🔥 BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loading ? null : savePassage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Programmer Passage",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}