import 'package:flutter/material.dart';
import 'package:smartbusudm/pages/inscriptLogin/connexion.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 178, 187, 223),

      body: Center(
        child: Container(
          width: 300,
          height: 500,
          decoration: BoxDecoration(
            
            
            borderRadius:BorderRadius.all(Radius.circular(30))
          ),
          child: Column(
            
            children: [
          ClipRect(
          child:Image.asset("assets/bus2.png",width: 20,height: 20,),
          ),
              Icon(Icons.person,
               size: 200,
               fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 92, 88, 88)
                ),
          
              SizedBox(height: 20),
          
            
              Text("felicien@gmail.com",style: TextStyle(
                fontSize: 20
              ),),
          
              SizedBox(height: 30),
          
              ListTile(
                textColor: Colors.blue,
                leading: Icon(Icons.edit),
                title: Text("Modifier profil",

                style: TextStyle(
               color: const Color.fromARGB(255, 32, 104, 238),
              ),),
                onTap: () {},
              ),
          
              ListTile(
                textColor: Colors.blue,
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text("Déconnexion",
                style: TextStyle(
                    color: const Color.fromARGB(255, 236, 22, 39),
                ),),
                onTap: () {
                  Navigator.push(context, 
                  MaterialPageRoute(builder: (context)=>Connexion()));
                  
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}