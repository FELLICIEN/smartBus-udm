import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> stations = [
    {"name": "Station de Belaba", "subtitle": "près du lycée moderne", "color": "blue"},
    {"name": "Station Rond point Mota", "subtitle": "Près du commissariat central 2 ", "color": "purple"},
    {"name": "Station Rond point Mota", "subtitle": "Près du commissariat central 2 ", "color": "green"},
    {"name": "Station Rond point de Koutou", "subtitle": "Près du rond point MIDI ", "color": "aqua"},
    {"name": "Station Marché mokolo(Guelkole)", "subtitle": "Résidence medard", "color": "purple"},
    {"name": "Station Rond point Mota", "subtitle": "Près du commissariat central 2 ", "color": "yellow"},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Stations'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'Bus'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/bus_bg.png'), //
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.blue.shade700.withOpacity(0.7), BlendMode.dstATop),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.directions_bus, color: Colors.blue),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SmartBus UDM', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Université de Moundou', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Bienvenue sur', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text('SmartBus UDM', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Consultez les stations et les horaires des bus en temps réel.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher une station...',
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stations list
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stations disponibles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Column(
                    children: stations.map((station) {
                      Color color;
                      switch (station['color']) {
                        case 'green':
                          color = Colors.green;
                          break;
                        case 'purple':
                          color = Colors.purple;
                          break;
                        default:
                          color = Colors.blue;
                      }
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(Icons.directions_bus, color: color),
                          title: Text(station['name']!),
                          subtitle: Text(station['subtitle']!),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Next bus info
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.blue.shade50,
                    child: ListTile(
                      leading: Icon(Icons.access_time, color: Colors.blue),
                      title: Text('Prochain bus le plus proche'),
                      subtitle: Text('Station A • 06:00 • Bus 102'),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Disponible', style: TextStyle(color: Colors.white)),
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