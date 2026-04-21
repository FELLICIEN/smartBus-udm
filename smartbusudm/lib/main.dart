import 'package:flutter/material.dart';
import 'package:smartbusudm/page/pageDrower/drawer.dart';
import 'package:smartbusudm/page/pageDrower/profile.dart';
import 'package:smartbusudm/pages/adminPages/admin_page.dart';
import 'package:smartbusudm/pages/adminPages/search.dart';
import 'package:smartbusudm/pages/bus/buspage.dart';
import 'package:smartbusudm/pages/station/station.dart';



void main()  {
  
  runApp(const MyApp());
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {



  int _currentIndex = 0;                       
  bool admin=true;
  

  void setCurrenPage(int index){
    setState(() {
      _currentIndex= index;
    });
   }


  @override
  Widget build(BuildContext context) {
    
    
    return MaterialApp(
           debugShowCheckedModeBanner: false,    
          theme: ThemeData(
           primaryColor: const Color.fromRGBO(9, 5, 203, 1),
          colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        

      ),
   
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: [
            Text("SmartBus Stations", style: TextStyle(fontFamily: "BoostPlay",fontSize: 30,color:Theme.of(context).primaryColor,)),
            Text("SmartBus Bus",style: TextStyle(fontFamily: "BoostPlay",fontSize: 30,color: Theme.of(context).primaryColor,)),
            Text("SmartBus Profile",style: TextStyle(fontFamily: "BoostPlay",fontSize: 30,color:Theme.of(context).primaryColor,)),
            admin?Text("SmartBus Administrations",style: TextStyle(fontFamily: "BoostPlay",fontSize: 30,color: Theme.of(context).primaryColor,)):null,
            Text("SmartBus Recherche",style: TextStyle(fontFamily: "BoostPlay",fontSize: 30,color:Theme.of(context).primaryColor,)),

           
          ][_currentIndex],
          
        ),
        body: [
          Station(),
          BusPage(),
          ProfilePage(),
          SearchPage(),
          AdminPage(),

        ][_currentIndex],
        drawer:DrawerPage() ,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blue,
          currentIndex: _currentIndex,


          onTap: (index){
            setCurrenPage(index);
          },


          selectedItemColor: const Color.fromARGB(255, 28, 47, 216),
          unselectedItemColor: Colors.grey,
          items: [

            BottomNavigationBarItem(
              label: "Station",
              icon: Icon(Icons.place,size: 30,
              )   ),

              BottomNavigationBarItem(
              label: "Bus",
              icon: Icon(Icons.directions_bus,size: 30
              )   ),

              BottomNavigationBarItem(
              label: "Moi",
              icon: Icon(Icons.person,size: 30
              )   ),

              BottomNavigationBarItem(
              label: "Recherche",
              icon: Icon(Icons.search,size: 30
              )   ),

              ?admin?(BottomNavigationBarItem(label: "Recherche",icon: Icon(Icons.admin_panel_settings_outlined,size: 30))):null
          ]),
      ),

    
    );
    
  }
}
