

import 'package:flutter/material.dart';
import 'package:smartbusudm/page/pageDrower/apropos.dart';

class Parametres extends StatefulWidget {
  const Parametres({super.key});

  @override
  State<Parametres> createState() => _ParametresState();
}

class _ParametresState extends State<Parametres> {
  bool notifications = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SmartBus ~ Paramètres",
       style: TextStyle(
        fontFamily: "BoostPlay",
        fontSize: 30,
      ),),
      backgroundColor: Theme.of(context).primaryColor
      ,)
      ,

      body: ListView(
      
        children: [
          

          SwitchListTile(
            title: Text("Notifications"),
            value: notifications,
            onChanged: (value) {
              setState(() {
                notifications = value;
              });
            },
          ),

          SwitchListTile(
            title: Text("Mode sombre"),
            value: darkMode,
            onChanged: (value) {
              setState(() {
                darkMode = value;
              });
            },
          ),

          ListTile(
            leading: Icon(Icons.info),
            title: Text("À propos"),
            onTap: () {
            Navigator.push(context,
            MaterialPageRoute(builder: (context)=>AproposPage()) 
            );
            },
          ),
        ],
      ),
    );
  }
}