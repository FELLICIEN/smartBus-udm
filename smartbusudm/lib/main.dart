import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartbusudm/firebase_options.dart';
import 'package:smartbusudm/pages/pageDrower/welcompage.dart';
import 'package:smartbusudm/services/bacground_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialisation du service GPS
  await BackgroundLocationService.initializeService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: const WelcomePage(),
    );
  }
}