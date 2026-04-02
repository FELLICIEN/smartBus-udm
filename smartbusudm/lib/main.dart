import 'package:flutter/material.dart';
import 'package:smartbusudm/pages/accueil.dart';
import 'package:smartbusudm/pages/bus.dart';
import 'package:smartbusudm/pages/connexion.dart';
import 'package:smartbusudm/pages/connexion2.dart';
import 'package:smartbusudm/pages/inscription.dart';
import 'package:smartbusudm/pages/politique.dart';
import 'package:smartbusudm/pages/stations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
debugShowCheckedModeBanner: false,     routes: {
      '/accueil':(context)=>HomeScreen(),
      '/stations':(context)=>Stations(),
      '/bus':(context)=>Bus(),
      '/connexion':(context)=>Connexion(),
      '/politique':(context)=>Politique(),
         '/login': (context) => LoginScreen(),
        '/inscrire': (context) => RegisterScreen(),
     },
      theme: ThemeData(
      primaryColor: Colors.blue,
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    
        backgroundColor: Theme.of(context).primaryColor,
    
        title: Text(widget.title),
      ),
      body: Center(
      
      ),
  
    );
  }
}
