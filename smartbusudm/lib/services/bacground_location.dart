import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

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
    await service.startService();
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();

    service.invoke("stop");

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final bus = await FirebaseFirestore.instance
          .collection('buses')
          .where('chauffeurId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (bus.docs.isNotEmpty) {
        await bus.docs.first.reference.update({
          'status': 'Disponible',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final bus = await FirebaseFirestore.instance
        .collection('buses')
        .where('chauffeurId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (bus.docs.isEmpty) return;

    final busRef = bus.docs.first.reference;

    await busRef.update({
      'status': 'En service',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      await busRef.update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'vitesse': position.speed * 3.6,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    service.on("stop").listen((event) {
      service.stopSelf();
    });
  }
}