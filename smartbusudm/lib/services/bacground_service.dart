import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ AJOUT
import 'package:flutter/widgets.dart';              // ✅ AJOUT
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

@pragma('vm:entry-point')
class BackgroundLocationService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        foregroundServiceNotificationId: 100,
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    print("DEMARRAGE SERVICE GPS");
    await service.startService();
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke("stop");
  }

  @pragma('vm:entry-point')
  static Future<void> onStart(ServiceInstance service) async {
    // ✅ INDISPENSABLE : initialiser Flutter + Firebase dans l'isolate background
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    await Firebase.initializeApp();

    print("SERVICE GPS DEMARRE");

    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        print("GPS DESACTIVE");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("PERMISSION GPS MANQUANTE");
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("UTILISATEUR NON CONNECTE");
        return;
      }

      print("UID = ${user.uid}");

      final query = await FirebaseFirestore.instance
          .collection('buses')
          .where('chauffeurId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print("AUCUN BUS ASSOCIE");
        return;
      }

      final busRef = query.docs.first.reference;

      await busRef.set({
        'status': 'En service',
        'tracking': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("TRACKING ACTIVE");

      // Première position immédiate
      try {
        Position firstPosition = await Geolocator.getCurrentPosition(
          // ignore: deprecated_member_use
          desiredAccuracy: LocationAccuracy.high,
        );
        await busRef.set({
          'latitude': firstPosition.latitude,
          'longitude': firstPosition.longitude,
          'vitesse': firstPosition.speed * 3.6,
          'tracking': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print("PREMIERE POSITION ENVOYEE");
        print('Position initiale : ${firstPosition.latitude}, ${firstPosition.longitude}, ${firstPosition.speed * 3.6} km/h');
      } catch (e) {
        print("ERREUR POSITION INITIALE : $e");
      }

      // Stream GPS continu
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 5,
        ),
      ).listen((Position position) async {
        try {
          if (position.latitude.isNaN || position.longitude.isNaN) {
            print("POSITION INVALIDE");
            return;
          }
          print("GPS => ${position.latitude}, ${position.longitude}");
          await busRef.set({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'vitesse': position.speed * 3.6,
            'tracking': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          print('Position envoyée : ${position.latitude}, ${position.longitude}, ${position.speed * 3.6} km/h');
        } catch (e) {
          print("ERREUR FIRESTORE : $e");
        }
      });

      service.on("stop").listen((event) async {
        await busRef.set({
          'status': 'Disponible',
          'tracking': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        service.stopSelf();
        print("SERVICE ARRETE");
      });

    } catch (e) {
      print("ERREUR SERVICE : $e");
    }
  }
}