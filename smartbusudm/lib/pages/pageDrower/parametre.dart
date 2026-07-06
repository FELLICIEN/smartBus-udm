import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbusudm/pages/pageDrower/apropos.dart';

class Parametres extends StatefulWidget {
  const Parametres({super.key});

  @override
  State<Parametres> createState() => _ParametresState();
}

class _ParametresState extends State<Parametres> {
  bool notifications = true;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  /// 📥 CHARGER LES PARAMÈTRES
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      notifications = prefs.getBool("notifications") ?? true;
      darkMode = prefs.getBool("darkMode") ?? false;
    });
  }

  /// 💾 SAUVEGARDER NOTIFICATIONS
  Future<void> saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("notifications", value);
  }

  /// 💾 SAUVEGARDER DARK MODE
  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? Colors.black : const Color(0xFFF4F6FA),

      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "SmartBus ~ Paramètres",
          style: TextStyle(
        
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'serif',
          ),
        ),
        backgroundColor: Colors.blue,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// 🔔 NOTIFICATIONS
          Card(
            child: SwitchListTile(
              title: const Text("Notifications"),
              subtitle: const Text("Activer les alertes bus"),
              value: notifications,
              onChanged: (value) {
                setState(() => notifications = value);
                saveNotifications(value);
              },
              secondary: const Icon(Icons.notifications),
            ),
          ),

          /// 🌙 DARK MODE (RÉEL)
          Card(
            child: SwitchListTile(
              title: const Text("Mode sombre"),
              subtitle: const Text("Changer l'apparence de l'app"),
              value: darkMode,
              onChanged: (value) {
                setState(() => darkMode = value);
                saveDarkMode(value);

                /// ⚠️ IMPORTANT: notification vers MaterialApp
                // tu dois connecter ça dans main.dart (je t'explique plus bas)
              },
              secondary: const Icon(Icons.dark_mode),
            ),
          ),

          const SizedBox(height: 10),

          /// ℹ️ À PROPOS
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text("À propos"),
              subtitle: const Text("Informations sur SmartBus"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AproposPage(),
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