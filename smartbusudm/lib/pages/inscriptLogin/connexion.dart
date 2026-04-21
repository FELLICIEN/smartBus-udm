import 'package:flutter/material.dart';
import 'package:smartbusudm/pages/inscriptLogin/inscription.dart';
import 'package:smartbusudm/pages/inscriptLogin/myapp.dart';

// ignore: must_be_immutable
class Connexion extends StatelessWidget {
 

 TextEditingController controllerEmail = TextEditingController();
 TextEditingController controllerMdp = TextEditingController();

  Connexion({super.key});


 


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                   Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage("assets/bus.png"),
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
                    controller: controllerEmail,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: "Adresse email",
                      label: Text("Adresse email"),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: controllerMdp,
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
                     String email = controllerEmail.text;
                     String mdp = controllerMdp.text;
                     if(email == "com" && mdp == "@"){
                       Navigator.pop(context);
                     Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context)=>MyApp(),
                        )
                        );
                     }
                     else{
                      Column(
                        children: [
                          Text("email ou mot de poasse incorrect",
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 0, 0),
                          ),)
                        ],
                      );
                     }
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
                          Navigator.push(context,
                          MaterialPageRoute(
                            builder: (context)=>Inscription()
                            )
                            );
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
      );
    
  }
}