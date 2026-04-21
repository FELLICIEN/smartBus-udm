import 'package:flutter/material.dart';
import 'package:smartbusudm/pages/adminPages/search.dart';

// ignore: must_be_immutable
class Inscription extends StatelessWidget {


 TextEditingController controllerNomComplet = TextEditingController();
 TextEditingController controllerEmail = TextEditingController();
 TextEditingController controllerMdp = TextEditingController();
 TextEditingController controllerMdpConfirme = TextEditingController();

 TextEditingController controllerRole = TextEditingController();

 

  // ignore: non_constant_identifier_names
  Inscription({super.key,ControlerRole});





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

            Text("Inscription",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextField(
                    controller: controllerNomComplet,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: "ex: Danra Félicien",
                      label:Text("Nom complet") ,
                      
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 15),

                  TextField(
                    controller: controllerEmail,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      label: Text("Adresse Email"),
                      hintText: "ex : danrafelicien@gmail.com",
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
                      label: Text("Mot de passe"),
                      hintText: "ex : password@1234",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 15),

                  TextField(
                    controller: controllerMdpConfirme,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      label: Text("Confirmer le mot de passe"),
                      hintText:"ex : password@1234" ,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                   TextField(
                    controller: controllerRole,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                     
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  SizedBox(height: 25),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      String nomComplet = controllerNomComplet.text;
                      String email = controllerEmail.text;
                      String mdp =controllerMdp.text;
                      String mdpConfirme = controllerMdpConfirme.text;
                      if(nomComplet=="com" && email == "@" && mdp.length>=4 && mdp == mdpConfirme){
                        Navigator.pop(context);
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder:(context)=>MyApp(),
                            )
                            );
                      }
                       else{
                      Column(
                        children: [
                          Text("saisies  incorrects",
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 0, 0),
                          ),)
                        ],
                      );
                     }
                    },
                    child: Text("S'inscrire",style: TextStyle(
                      fontSize: 25,
                    ),),
                  ),

                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Déjà un compte ? "),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Se connecter"),
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