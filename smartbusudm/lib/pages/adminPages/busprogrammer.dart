import 'package:flutter/material.dart';
 
class BusProgrammer extends StatefulWidget {
  const BusProgrammer({super.key});
 
  @override
  State<BusProgrammer> createState() => _BusProgrammerState();
}
 
class _BusProgrammerState extends State<BusProgrammer> {
  String? busSel;
  String? stationSel;
  String? heureSel;
 
  void programmerBus() {
    if (busSel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner un bus")),
      );
      return;
    }
    if (stationSel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une station")),
      );
      return;
    }
    if (heureSel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une heure")),
      );
      return;
    }
 
    // ✅ Tous les champs sont valides, on peut enregistrer la programmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bus programmé avec succès ✅")),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Programmer un bus"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      // 🩹 Toute la page est maintenant défilable, avec une icône de taille
      // raisonnable, pour laisser assez de place aux menus déroulants
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Icon(Icons.bus_alert_outlined, size: 100),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.green,
                child: Column(
                  children: [
                    /// 🚌 CHOIX DU BUS
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: DropdownButtonFormField<String>(
                        initialValue: busSel,
                        decoration: const InputDecoration(
                          labelText: "Bus",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'bus1', child: Text("Bus 1")),
                          DropdownMenuItem(value: 'bus2', child: Text("Bus 2")),
                          DropdownMenuItem(value: 'bus3', child: Text("Bus 3")),
                        ],
                        onChanged: (String? value) {
                          setState(() => busSel = value);
                        },
                      ),
                    ),
 
                    /// 📍 CHOIX DE LA STATION
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: DropdownButtonFormField<String>(
                        initialValue: stationSel,
                        decoration: const InputDecoration(
                          labelText: "Station",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'stat1', child: Text("Station 1")),
                          DropdownMenuItem(value: 'stat2', child: Text("Station 2")),
                          DropdownMenuItem(value: 'stat3', child: Text("Station 3")),
                        ],
                        onChanged: (String? value) {
                          setState(() => stationSel = value);
                        },
                      ),
                    ),
 
                    /// 🕐 CHOIX DE L'HEURE
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: DropdownButtonFormField<String>(
                        initialValue: heureSel,
                        decoration: const InputDecoration(
                          labelText: "Heure",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: '1', child: Text("05:00")),
                          DropdownMenuItem(value: '2', child: Text("05:30")),
                          DropdownMenuItem(value: '3', child: Text("06:00")),
                        ],
                        onChanged: (String? value) {
                          setState(() => heureSel = value);
                        },
                      ),
                    ),
 
                    const SizedBox(height: 10),
 
                    ElevatedButton(
                      onPressed: programmerBus,
                      child: const Text("Programmer un bus"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
