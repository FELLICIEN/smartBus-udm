import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:smartbusudm/models/station_model.dart';
import 'package:smartbusudm/services/station_service.dart';

class AddStationPage extends StatefulWidget {
  const AddStationPage({super.key});

  @override
  State<AddStationPage> createState() => _AddStationPageState();
}

class _AddStationPageState extends State<AddStationPage> {
  final nomController = TextEditingController();
  final descriptionController = TextEditingController();
  final addresseController = TextEditingController();

  bool loading = false;
  String error = "";

  void saveStation() async {
    if (nomController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        addresseController.text.isEmpty) {
      setState(() => error = "Remplis tous les champs");
      return;
    }

    setState(() {
      loading = true;
      error = "";
    });

    try {
      final station = Station(
        id: const Uuid().v4(),
        nom: nomController.text.trim(),
        description: descriptionController.text.trim(),
        adresse: addresseController.text.trim(),
      );

      await StationService().addStation(station);

      if (!mounted) return;

      /// ✅ SUCCESS SNACKBAR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Station ajoutée avec succès ✅"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;

      /// ❌ ERROR SNACKBAR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() => loading = false);
  }

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      /// 🔵 APPBAR AJOUTÉ
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Ajouter une station",
        style: TextStyle(
                fontSize: 30,
                fontWeight:FontWeight.bold,
                color: Colors.white,
                fontFamily: "BoostPlay",
                ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔵 HEADER PRO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.location_on,
                      size: 70, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "SmartBus ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Création d’une station",
                    style: TextStyle(color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    ),
                    
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// 🧾 FORMULAIRE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  TextField(
                    controller: nomController,
                    decoration: inputStyle("Nom de la station", Icons.location_on),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: descriptionController,
                    decoration: inputStyle("Description", Icons.description),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: addresseController,
                    decoration: inputStyle("Adresse", Icons.location_pin),
                  ),

                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        error,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 25),

                  /// 🔘 BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : saveStation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Ajouter une station",
                              style: TextStyle(fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,),
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