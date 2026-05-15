import 'package:flutter/material.dart';
import 'package:smartbusudm/pages/add/add_passage.dart';
import 'package:smartbusudm/pages/adminPages/bus_admin_page.dart';
import 'package:smartbusudm/pages/adminPages/station_page_admin.dart';
import 'package:smartbusudm/pages/adminPages/user_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔵 HEADER PREMIUM
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [

                  const SizedBox(height: 40),

                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings,
                        size: 40, color: Colors.blue),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Admin Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Gestion SmartBus",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),


            const SizedBox(height: 20),

            /// 🧱 GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GridView.count(
                crossAxisCount: screenWidth < 600 ? 2 : 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [

                  buildCard(
                    icon: Icons.directions_bus,
                    title: "Bus",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AdminBusPage()));
                    },
                  ),

                  buildCard(
                    icon: Icons.location_on,
                    title: "Stations",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => StationsPage()));
                    },
                  ),

                  buildCard(
                    icon: Icons.access_time,
                    title: "Programmation\n des passages",
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AddPassagePage()));
                    },
                  ),

                  buildCard(
                    icon: Icons.people,
                    title: "Utilisateurs",
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => UsersPage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 STAT CARD MODERNE
  Widget statCard(IconData icon, String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// 🧱 CARD PREMIUM
  Widget buildCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35, color: color),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        
        ),
      ),
    );
  }
}