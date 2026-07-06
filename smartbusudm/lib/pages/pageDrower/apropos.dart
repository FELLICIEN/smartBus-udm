import 'package:flutter/material.dart';

class AproposPage extends StatelessWidget {
  const AproposPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 178, 187, 223),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("SmartBus ~ A propos",   style: TextStyle(
        
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'serif',
          ),),
        centerTitle: true,

        ),
      

      body: SingleChildScrollView(
        child: Column(
          children: [

            ///  HEADER AVEC IMAGE BUS
            Container(
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
            ),

            ///  TITRE
            const Text(
              "SmartBus UDM",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color:  Colors.blue,
              ),
            ),

            const SizedBox(height: 10),

            ///  VERSION
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                " 📱 Version 1.0",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📦 CARD DESCRIPTION
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: const [

                  Icon(Icons.access_time,
                      size: 40, color: Colors.orange),

                  SizedBox(height: 10),

                  Text(
                    " Cette application permet de consulter les horaires des bus universitaires en temps réel.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 📍 FOOTER
            Column(
              children: const [
                Icon(Icons.location_on,
                    color: Colors.blue),

                SizedBox(height: 5),

                Text(
                  "UDM • Mobilité intelligente",
                  style: TextStyle(color: Colors.blue,fontFamily: "BoostPlay",fontSize: 25),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}