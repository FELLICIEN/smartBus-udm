import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartbusudm/pages/espace_chauffeur/chauffeurs_page.dart';
import 'package:smartbusudm/pages/pageDrower/chat_page.dart';

import 'package:smartbusudm/pages/pageDrower/drawer.dart';
import 'package:smartbusudm/pages/pageDrower/profile.dart';
import 'package:smartbusudm/pages/adminPages/admin_page.dart';
import 'package:smartbusudm/pages/station/all_bus_page.dart';
import 'package:smartbusudm/pages/station/station.dart';

class SecondePage extends StatefulWidget {
  const SecondePage({super.key});

  @override
  State<SecondePage> createState() => _SecondePageState();
}

class _SecondePageState extends State<SecondePage> {
  int _currentIndex = 0;
  bool isAdmin = false;
  bool isLoading = true;
  bool isChauffeur = false;
  

  final user = FirebaseAuth.instance.currentUser;

  List<Widget> pages = [];
  List<String> titles = [];

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }


  Future<void> showerreur(String err) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err)),
    );
  }

  /// 🔥 Charger le rôle depuis Firestore
  Future<void> loadUserRole() async {
    try {
      if (user == null) {
        showerreur("Utilisateur non connecté");

        buildPages();
        setState(() => isLoading = false);
        return;
      }

   

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      final data = doc.data();

      if (data != null) {
        final role = data['role'] ?? 'user';
        isAdmin = role == 'admin';
        isChauffeur = role == 'chauffeur';
      } else {
       showerreur(" utilisateur introuvable");
      }

    } catch (e) {
      showerreur("Erreur Firestore: $e");
    }

    buildPages();

    setState(() => isLoading = false);
  }

  /// 🔥 Construire pages dynamiquement
  void buildPages() {
    pages = [
      const StationPage(),
      const AllBusPage(),
      const ProfilePage(),
      if (isAdmin) const AdminPage(),
      if (isChauffeur) const ChauffeurPage(), 
      const ChatPage(),
    ];

    titles = [
      "Stations",
      "Bus",
      "Profile",
      if (isAdmin) "Administration",
      if (isChauffeur) "Chauffeur",
      "Discussions",
    ];
  }

  void setPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// 🔥 Loader sécurisé
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "SmartBus ${titles[_currentIndex]}",
          style: TextStyle(
        
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'serif',
          ),
        ),
      ),

      drawer: const DrawerPage(),

      body: pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: setPage,
        type: BottomNavigationBarType.fixed,

        backgroundColor: Colors.blue,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,

        items: [
          const BottomNavigationBarItem(
            label: "Stations",
            icon: Icon(Icons.location_on),
          ),
            const BottomNavigationBarItem(
              label: "Bus",
              icon: Icon(Icons.directions_bus),
            ),
          

          const BottomNavigationBarItem(
            label: "Profile",
            icon: Icon(Icons.person),
          ),

          if (isAdmin)
            const BottomNavigationBarItem(
              label: "Administration",
              icon: Icon(Icons.admin_panel_settings),
            ),

          if (isChauffeur)
            const BottomNavigationBarItem(
              label: "Espace Chauffeur",
              icon: Icon(Icons.drive_eta),
            ),

          const BottomNavigationBarItem(
            label: "Discussions",
            icon: Icon(Icons.chat),
          ),
        
        ],
      ),
    );
  }
}