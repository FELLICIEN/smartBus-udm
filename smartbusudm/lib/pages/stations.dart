

import 'package:flutter/material.dart';

class Stations extends StatelessWidget {
  const Stations({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("smartBus udm - Station"),
         backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
        children: [
          Text("liste des stations"),
          Container(
            height: 60,
            width: double.infinity,
            color: Colors.blue,
          ),
          TextButton(onPressed: (){
            Navigator.pushNamed(context, "/login");
          }, 
          child:Text("connexion") ),
        ],
        ),
      ),
    );
  }
}