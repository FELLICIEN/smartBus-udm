

import 'package:flutter/material.dart';

class Bus extends StatelessWidget {
  const Bus({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("smartBus udm - Bus",
         style: TextStyle(
        fontFamily: "BoostPlay",
        fontSize: 30,
      ),),
         backgroundColor: Theme.of(context).primaryColor,
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