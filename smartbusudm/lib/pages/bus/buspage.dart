import 'package:flutter/material.dart';
import 'package:smartbusudm/pages/bus/buscard.dart';

class BusPage extends StatefulWidget {
  const BusPage({super.key});

  @override
  State<BusPage> createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [


          /// HEADER AVEC IMAGE
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              image: const DecorationImage(
                image: AssetImage("assets/bus2.png"),
                fit: BoxFit.cover,
              ),
            ),

            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
               
              ),

              padding: const EdgeInsets.only(
                  top: 50, 
                  left: 20,
                  right: 20,
                  bottom: 30
                  ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

               
                  const Spacer(),

                  ///  TITRE
                  Text(
                    "Bus Disponibles",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "Tous les bus actuellement disponibles",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 📋 LISTE DES BUS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: const [

                BusCard(
                  busNumber: "Bus 102",
                  status: "Disponible",
                  color: Colors.green,
                ),

                BusCard(
                  busNumber: "Bus 123",
                  status: "Occupé",
                  color: Colors.orange,
                ),

                BusCard(
                  busNumber: "Bus 209",
                  status: "Hors service",
                  color: Colors.grey,
                ),

                BusCard(
                  busNumber: "Bus 351",
                  status: "Disponible",
                  color: Colors.green,
                ),

                BusCard(
                  busNumber: "Bus 400",
                  status: "Disponible",
                  color: Colors.green,
                ),

                BusCard(
                  busNumber: "Bus 500",
                  status: "Occupé",
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),

     
    );
  }
}