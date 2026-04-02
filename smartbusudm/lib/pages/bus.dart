

import 'package:flutter/material.dart';

class Bus extends StatelessWidget {
  const Bus({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("smartBus udm - Bus"),
         backgroundColor: Theme.of(context).primaryColor,
actions: [
  IconButton(onPressed: (){
    Navigator.pop(context);
    Navigator.pushNamed(context, "/connexion");
  }, 
  icon: Icon(Icons.logout))
],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("les stations  actuellements",style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight(30),)),
           ]
        
        ),
        
      ),
    );
  }
}