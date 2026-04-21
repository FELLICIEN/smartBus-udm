import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  // 🔹 Liste originale
  List<String> busList = [
   "Station de Belaba", 
   "Station Rond point Mota",
   "Station Rond point Moirom",
   "Station de koutou", 
   "Station Medard",
   "Station Rond point Maitrie" ,
   "Station Marché mokolo(Guelkole)",

      "Station Rond point X",
   "Station Rond point Z",
   "Station de Y", 
   "Station A",
   "Station Rond point G" ,
   "Station Marché M"

    ];
  //  Liste affichée
  List<String> filteredList = [];

  @override
  void initState() {
    super.initState();
    filteredList = busList; // afficher tout au début
  }

  //  Fonction de recherche
  void search(String query) {
    setState(() {
      filteredList = busList.where((bus) {
        return bus.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      body: Column(
        children: [

          // 🔎 Champ de saisie
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                search(value); // 🔥 mise à jour en temps réel
              },
              decoration: InputDecoration(
                hintText: "Rechercher un bus...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 📋 Liste affichée
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.directions_bus,
                        color: Colors.blue),
                    title: Text(filteredList[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}