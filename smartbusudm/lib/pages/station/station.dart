import 'package:flutter/material.dart';


class Station extends StatefulWidget {
   const Station({super.key});

  @override
  State<Station> createState() => _StationState();
}

class _StationState extends State<Station> {
  final List<Map<String, String>> stations = [

    {"name": "Station Rond point de Koutou", "subtitle": "Près du rond point MIDI ", "color": "aqua"},
    {"name": "Station Marché mokolo(Guelkole)", "subtitle": "Résidence medard", "color": "purple"},
    {"name": "Station Rond point Mota", "subtitle": "Près du commissariat central 2 ", "color": "yellow"},


    {"name": "Station de Belaba", "subtitle": "près du lycée moderne", "color": "blue"},
    {"name": "Station Rond point Mota", "subtitle": "Près du commissariat central 2 ", "color": "purple"},
    {"name": "Station Rond point Mota", "subtitle": "Près du commissariat central 2 ", "color": "green"},
    {"name": "Station Rond point Mota", "subtitle": "Près du commissariat central 2 ", "color": "green"},

    {"name": "Station Rond point de Koutou", "subtitle": "Près du rond point MIDI ", "color": "aqua"},
    {"name": "Station Marché mokolo(Guelkole)", "subtitle": "Résidence medard", "color": "purple"},
    {"name": "Station Rond point Mota", "subtitle": "Près du commissariat central 2 ", "color": "yellow"},



  ];
  


Future<void> dialogue() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
        backgroundColor: const Color.fromARGB(255, 204, 203, 209),
        title: Text("Stations",
        style: const TextStyle(fontFamily: "BoostPlay"),
        ),
        content: const SingleChildScrollView(
          child: ListBody(
          
            children: <Widget>[
              
              Icon(Icons.directions_bus_sharp,size: 100,),
              Text('bus de la stattion x.',style:TextStyle(color: Color.fromARGB(255, 43, 34, 34)),),
              Text('exemple contenu',style:TextStyle(color: Color.fromARGB(255, 41, 35, 35)),
              )
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Fermer',style:TextStyle(color: Color.fromARGB(255, 34, 22, 22))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
  
    return SingleChildScrollView(
      
        child: Column(
          
          
          children: [
          
         
            // Header
            Container(
              
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: BoxDecoration(
                
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                image: DecorationImage(
                opacity: 50,
                  image: AssetImage('assets/bus.png',), //
                  fit: BoxFit.cover,
                
                  // ignore: deprecated_member_use
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                         
               
                  Row(
                    children: [
                      CircleAvatar(
                      backgroundImage: AssetImage("assets/udm.png"),
                      radius: 25,
                      ),
                      Padding(padding: EdgeInsets.only( top: 15)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SmartBus UDM', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold,fontFamily: "BoostPlay")),
                          Text('Université de Moundou', style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Bienvenue sur', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          Text('SmartBus UDM', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold,fontFamily: "BoostPlay")),
                 
                  SizedBox(height: 10),
                  Text('Consultez les stations et les horaires des bus en temps réel.', style: TextStyle(color: Colors.white70, fontSize: 16)),
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
                          onTap: () {
                            dialogue();
                          }                                                 ,
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),





    
                  // Next bus info
                  /*
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
                  */
                ],
                
              ),
            ),
          ],
          
        ),
    );
 }

 }