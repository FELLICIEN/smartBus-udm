

import 'package:flutter/material.dart';

class Gps extends StatefulWidget {

  final String busId;
  final String busName;
  final String busStatus;
  final String busLocation; // Ajout de la localisation du bus

  const Gps({
    super.key,
    required this.busId,
    required this.busName,
    required this.busStatus,
    required this.busLocation,
  });
  @override
  State<Gps> createState() => _GpsState();
}



  /// 🎨 COLOR STATUS
  Color getColor(String status) {
    switch (status.toLowerCase()) {
      case "disponible":
        return Colors.green;

      case "en service":
        return Colors.orange;

      case "en panne":
        return Colors.red;

      default:
        return Colors.grey;
    }
  } 

class _GpsState extends State<Gps> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SmartBus GPS",
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
        ),
       
        ),
        actions: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.only(right: 16),
              color:getColor(widget.busStatus), // Couleur basée sur le statut du bus
              alignment: Alignment.center,
              child: Text("Bus ${widget.busName}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),),
            ),
          )
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          alignment: Alignment.center,  
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text("Cette fonctionnalité est en construction ...",
                style: const TextStyle(
                  color: Color.fromARGB(255, 18, 14, 216),
                  fontSize: 20,
                  ),),
                  Text("Position actuelle du bus :\n ${widget.busLocation};",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),),
              ],
            ),
          )),
      ),
    );
  }
}