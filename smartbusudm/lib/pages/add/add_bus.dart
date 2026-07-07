import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
 
import 'package:smartbusudm/models/bus_model.dart';
import '../../services/bus_service.dart';
 
class AddBusPage extends StatefulWidget {
  const AddBusPage({super.key});
 
  @override
  State<AddBusPage> createState() => _AddBusPageState();
}
 
class _AddBusPageState extends State<AddBusPage> {
  final nomController = TextEditingController();
  final numeroController = TextEditingController();
  final capaciteController = TextEditingController();
 
  bool isLoading = false;
  String error = "";
 
  String? selectedChauffeur;
  String? selectedStatus = "Disponible";
 
  /// 🔥 STREAM CHAUFFEURS (temps réel)
  Stream<QuerySnapshot> getChauffeurs() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'chauffeur')
        .snapshots();
  }
 
  /// 🚌 STREAM DES BUS (pour connaître les chauffeurs déjà assignés)
  Stream<QuerySnapshot> getBuses() {
    return FirebaseFirestore.instance.collection('buses').snapshots();
  }
 
  /// 🔥 LISTE STATUS
  final List<String> statusList = [
    "Disponible",
    "En service",
    "En panne",
  ];
 
  /// 🔒 Vérifie qu'un chauffeur n'est pas déjà assigné à un autre bus.
  /// Retourne true si LIBRE (peut être assigné), false si déjà pris.
  Future<bool> isChauffeurAvailable(String chauffeurId) async {
    final existing = await FirebaseFirestore.instance
        .collection('buses')
        .where('chauffeurId', isEqualTo: chauffeurId)
        .limit(1)
        .get();
    return existing.docs.isEmpty;
  }
 
  /// 🔥 SAVE BUS
  Future<void> saveBus() async {
    if (nomController.text.isEmpty ||
        numeroController.text.isEmpty ||
        capaciteController.text.isEmpty ||
        selectedChauffeur == null ||
        selectedStatus == null) {
      setState(() {
        error = "Tous les champs sont obligatoires";
      });
      return;
    }
 
    setState(() {
      isLoading = true;
      error = "";
    });
 
    try {
      // 🔒 Double vérification au moment de l'enregistrement : un chauffeur
      // ne peut être assigné qu'à un seul bus (protège contre les créations
      // concurrentes depuis deux appareils admin en même temps)
      final available = await isChauffeurAvailable(selectedChauffeur!);
      if (!available) {
        setState(() {
          error = "Ce chauffeur est déjà assigné à un autre bus";
          isLoading = false;
          selectedChauffeur = null;
        });
        return;
      }
 
      /// 🔥 récupérer nom chauffeur
      final chauffeurDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(selectedChauffeur)
          .get();
 
      final chauffeurNom =
          chauffeurDoc.data()?['nom'] ?? "Chauffeur";
      final chauffeurId = chauffeurDoc.id;
 
      final bus = Bus(
        id: const Uuid().v4(),
        nom: nomController.text.trim(),
        numero: numeroController.text.trim(),
        capacite:
            int.tryParse(capaciteController.text) ?? 0,
 
        chauffeur: chauffeurNom,
 
        chauffeurId: chauffeurId,
        date: DateTime.now(),
        status: selectedStatus!,
      );
 
      /// 🔥 sauvegarde bus
      await BusService().addBus(bus);
 
      /// 🔥 OPTIONNEL : enregistrer aussi relation chauffeur
      await FirebaseFirestore.instance
          .collection('buses')
          .doc(bus.id)
          .set({
        'id': bus.id,
        'nom': bus.nom,
        'numero': bus.numero,
        'capacite': bus.capacite,
        'status': bus.status,
        'date': bus.date,
        'chauffeurId': chauffeurId,
        'chauffeur': chauffeurNom,
      });
 
      if (!mounted) return;
 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bus ajouté avec succès 🚍"),
          backgroundColor: Colors.green,
        ),
      );
 
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        error = "Erreur : $e";
      });
    }
 
    setState(() {
      isLoading = false;
    });
  }
 
  /// 🎨 INPUT DESIGN
  Widget input(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          prefixIcon: Icon(icon, color: Colors.blue),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
 
  /// 🚨 DROPDOWN CHAUFFEUR (LIVE) — n'affiche que les chauffeurs LIBRES
  /// (pas encore assignés à un bus), garantissant la relation 1-pour-1
  Widget chauffeurDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: StreamBuilder<QuerySnapshot>(
        stream: getBuses(),
        builder: (context, busSnapshot) {
          if (!busSnapshot.hasData) {
            return const CircularProgressIndicator();
          }
 
          // 🔒 IDs des chauffeurs déjà assignés à un bus existant
          final assignedChauffeurIds = busSnapshot.data!.docs
              .map((doc) => (doc.data() as Map<String, dynamic>)['chauffeurId'])
              .where((id) => id != null)
              .cast<String>()
              .toSet();
 
          return StreamBuilder<QuerySnapshot>(
            stream: getChauffeurs(),
            builder: (context, chauffeurSnapshot) {
              if (!chauffeurSnapshot.hasData) {
                return const CircularProgressIndicator();
              }
 
              final docs = chauffeurSnapshot.data!.docs;
 
              // 🔒 On ne garde que les chauffeurs NON assignés
              final availableDocs = docs
                  .where((doc) => !assignedChauffeurIds.contains(doc.id))
                  .toList();
 
              return DropdownButtonFormField<String>(
                initialValue: selectedChauffeur,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                  labelText: availableDocs.isEmpty
                      ? "Aucun chauffeur disponible"
                      : "Choisir un chauffeur",
                  helperText: availableDocs.isEmpty
                      ? "Tous les chauffeurs sont déjà assignés à un bus"
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: availableDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nom = data['nom'] ?? "Chauffeur";
 
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(nom),
                  );
                }).toList(),
                onChanged: availableDocs.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          selectedChauffeur = value;
                        });
                      },
              );
            },
          );
        },
      ),
    );
  }
 
  /// 🔥 DROPDOWN STATUS
  Widget statusDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownButtonFormField<String>(
        initialValue: selectedStatus,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          prefixIcon: const Icon(
            Icons.info_outline,
            color: Colors.blue,
          ),
          labelText: "Status",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        items: statusList.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(status),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedStatus = value;
          });
        },
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
 
      appBar: AppBar(
        title: const Text(
          "SmartBus",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontFamily: "BoostPlay",
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
      ),
 
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF42A5F5),
                    Color(0xFF1565C0),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.directions_bus,
                    size: 70,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Ajouter un Bus",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
 
            const SizedBox(height: 20),
 
            /// FORM
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  input("Nom du bus", Icons.directions_bus,
                      nomController),
 
                  input("Numéro du bus",
                      Icons.confirmation_number,
                      numeroController),
 
                  input("Capacité", Icons.people,
                      capaciteController,
                      type: TextInputType.number),
 
                  chauffeurDropdown(),
 
                  statusDropdown(),
 
                  if (error.isNotEmpty)
                    Text(
                      error,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
 
                  const SizedBox(height: 20),
 
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : saveBus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Ajouter le bus",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
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
