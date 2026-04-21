import 'package:flutter/material.dart';

import 'package:smartbusudm/pages/bus/buspage.dart';
import 'package:smartbusudm/pages/station/station.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          
          children: [
           
               Container(
                width: double.infinity,
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage("assets/bus2.png"),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Administration",style: TextStyle(
                        color: Colors.white,
                        fontSize: 150,
                        
                        fontFamily: "BoostPlay",
                        fontWeight: FontWeight.bold,)),
                ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(15.0),
              
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
            
                  buildCard(
                    icon: Icons.directions_bus,
                    title: "Gestion des Bus",
                    onTap: () {
                      Navigator.push(context, 
                      MaterialPageRoute(builder: (context)=>BusPage()));
                    },
                  ),
            
                  buildCard(
                    icon: Icons.location_on,
                    title: "Gestion des Stations",
                    onTap: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context)=>Station()));
                    },
                  ),
            
                  buildCard(
                    icon: Icons.access_time,
                    title: "Programmer Bus",
                    onTap: () {
                      Navigator.pushNamed(context, "/passages");
                    },
                  ),
            
                  buildCard(
                    icon: Icons.people,
                    title: "Utilisateurs",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}