

import 'package:flutter/material.dart';



class Connexion extends StatefulWidget {
   Connexion({super.key});


  @override
  State<Connexion> createState() => _ConnexionState();
}


 TextEditingController controllerEmail = TextEditingController();
 TextEditingController controllerMdp = TextEditingController();
 TextEditingController controllerNom = TextEditingController();
 TextEditingController controllerPrenom= TextEditingController();


class _ConnexionState extends State<Connexion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
    title: Text("Connexion ",
    style: TextStyle(
      fontSize: 30,
    ),),
    backgroundColor: Theme.of(context).primaryColor,
    ),
     body:  SingleChildScrollView(child:
    Card.outlined(
     
  child: Column(

   
          children: [
            SizedBox(height: 10,),
            Icon(Icons.lock),
             Container(
              margin: EdgeInsets.all(20),
               child: TextFormField(
                 controller: controllerNom,
                 
                 decoration: InputDecoration(
                   label: Text("Votre nom"),
                   hintText: "ex: Danra",
                   suffixIcon:Icon(Icons.person),
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(15),
                   )
                 ),
                 
               ),
             ),

             Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                
                controller: controllerPrenom,
                decoration: InputDecoration(
                 label: Text("Votre prenom"),
                  hintText: "ex: Félicien",
                  suffixIcon:Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  )
                ),
                
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: controllerEmail,
                decoration: InputDecoration(
                 label: Text("Votre email"),
                  hintText: "ex: danrafelicien@gmail.com",
                  suffixIcon:Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  )
                ),
                
              ),
            ),
             Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                obscureText: true,
                controller: controllerMdp,
                decoration: InputDecoration(
                  hintText: "Votre mot de passe",
                  label: Text( "Mot d passe"),
                  suffixIcon:Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  )
                ),
                
              ),

              
              
            ),

            
            TextButton.icon(onPressed: (){
              String email = controllerEmail.text;
              String mdp = controllerMdp.text;
              String nom =controllerNom.text;
              String prenom = controllerPrenom.text;
             if(email !=""&& mdp.length>4 && nom !="" && prenom !=""){ 
              
              Navigator.of(context).pop();
              Navigator.pushNamed(context,
               "/accueil");
               setState(() {
                 controllerEmail.text="";
               controllerMdp.text="";
               });
             }else{
              "email ou mot de passe invalide";
             }
            }, 
            label: Text("Se connecter"),
            icon: Icon(Icons.login),)
          ],
            
          
          ),
),),
    );
  }
}
