import 'package:flutter/material.dart';
import 'package:smartbusudm/pages/espace_chauffeur/chauffeurs_page.dart';
import 'package:smartbusudm/pages/pageDrower/apropos.dart';
import 'package:smartbusudm/pages/pageDrower/helppage.dart';
import 'package:smartbusudm/pages/pageDrower/parametre.dart';
import 'package:smartbusudm/pages/pageDrower/politique.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      
      backgroundColor:const Color.fromARGB(255, 178, 187, 223),
      elevation: 18.0,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color:Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20)
            ),
            curve: Curves.linear,
          child: Row(
          
              mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
  
  CircleAvatar(
    radius: 40,
    backgroundImage: AssetImage('assets/udm.png'),
  ),
  CircleAvatar(
    radius: 50,
    backgroundImage: AssetImage('assets/cnou_icon.png'),
  ),
],
          )
          )
         ,

       
         ListTile(

        leading: Icon(Icons.settings),
        title: Text("Parametre"),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context,
          MaterialPageRoute(builder: (context)=>Parametres())
          );
          
        },
        trailing:Icon(Icons.forward) ,

         ),

         ListTile(
        title: Text("Chauffeurs "),
        leading: Icon(Icons.drive_eta),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context,
          MaterialPageRoute(builder: (context)=>ChauffeurPassagesPage())
          );
        },
        trailing:Icon(Icons.forward)  ,
         ),

         ListTile(

        title: Text("Aide"),

        leading: Icon(Icons.live_help),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context,
          MaterialPageRoute(builder: (context)=>HelpPage())
          );
        },
        trailing:Icon(Icons.forward)  ,
         ),
          Column(
            children: [
              ListTile(
              
              
                      leading: Icon(Icons.podcasts),
                      title: Text("Politique"),
                      onTap: () {
                       Navigator.pop(context);
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context)=>PolitiqueConfidentialitePage())
                      );
                      },
                      trailing:Icon(Icons.forward)  ,
                       ),
            ],
          ),
          ListTile(
          
            leading: Icon(Icons.app_shortcut_rounded),
        title: Text("A propos"),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, 
          MaterialPageRoute(
            builder: (context)=>AproposPage()
            )
          );
        },
        trailing:Icon(Icons.forward)  ,
         ),
        
         
        ]
        
      ),
    );
  }
}