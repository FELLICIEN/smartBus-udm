import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override



 


  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                   SizedBox(height: 20,),
                  Icon(Icons.directions_car, size: 80, color: Colors.white),
                  SizedBox(height: 10),
                  Text("SmartBus UDM",
                      style: TextStyle(
                        color: Colors.white,
                         fontSize: 30,
                         fontWeight: FontWeight.w300)),
                ],
              ),
            ),

            SizedBox(height: 30),

            Text("Connexion",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: "Adresse Email",
                      label: Text("Adresse email"),

                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: "Mot de passe",
                      label: Text("Mot de passe"),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  SizedBox(height: 25),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/accueil");
                    },
                    child: Text("Se connecter"
                    ,style: TextStyle(
                      fontSize: 25,
                    ),),
                  ),

                  SizedBox(height: 10),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Pas de compte ? "),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/inscrire");
                        },
                        child: Text("S'inscrire"),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}