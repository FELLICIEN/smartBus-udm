import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text("Aide & Support",
          style: TextStyle(
        
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'serif',
          ),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// 🔵 HEADER MODERNE
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.indigo],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.support_agent, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text(
                  "Centre d'aide",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Tout ce que vous devez savoir sur SmartBus",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 🔹 STATUTS
          const Text(
            "Statuts des bus",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          statusItem("Disponible", "Le bus est libre et prêt.", Colors.green),
          statusItem("En service", "Le bus circule actuellement.", Colors.blue),
          statusItem("En panne", "Bus indisponible pour maintenance.", Colors.red),

          const SizedBox(height: 20),

          /// 🔹 FAQ
          const Text(
            "Questions fréquentes (FAQ)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          buildFAQ(
            "Comment voir les bus disponibles ?",
            "Allez dans la page Bus pour voir tous les bus en temps réel.",
          ),
          buildFAQ(
            "Comment consulter les bus de chaque station ?",
            "Ouvrez la page Stations et cliquez sur une station que vous desirez voir les passages dans cette dernière."),

          buildFAQ(
            "Comment consulter les stations ?",
            "Ouvrez la page Stations pour voir toutes les stations.",
          ),

          buildFAQ(
            "Que signifie 'Hors service ou En panne' ?",
            "Le bus est temporairement indisponible pour maintenance.",
          ),

          const SizedBox(height: 20),

          /// 🔹 CONTACT
          const Text(
            "Contact",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          contactCard(Icons.email, "Email", "cnou@gmail.com"),
          contactCard(Icons.phone, "Téléphone", "+235 60 07 71 50"),

          const SizedBox(height: 25),

          Center(
            child: Text(
              "SmartBus  v1.0",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  /// 🟢 STATUS CARD MODERN
  static Widget statusItem(String title, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          // ignore: deprecated_member_use
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.directions_bus, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(desc),
      ),
    );
  }

  /// 🔵 FAQ MODERN
  Widget buildFAQ(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: Colors.blue),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// 📞 CONTACT CARD
  static Widget contactCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}