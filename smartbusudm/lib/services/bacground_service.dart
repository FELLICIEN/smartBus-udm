import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
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
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    await Firebase.initializeApp();
 
    print("SERVICE GPS DEMARRE");
 
    DocumentReference<Map<String, dynamic>>? busRef;
 
    try {
      // ---------------------------------------------------------------
      // ⚠️ IMPORTANT : on NE ré-appelle PAS Geolocator.checkPermission()
      // ou requestPermission() ici. Ce service tourne dans un isolate
      // "headless" (sans Activity Android), et ces méthodes lèvent
      // l'erreur "Activity is missing" dans ce contexte.
      //
      // Les permissions ont DÉJÀ été vérifiées côté UI (ChauffeurPage,
      // avant l'appel à startService()). On fait donc confiance à cette
      // vérification et on tente directement de lire la position, en
      // capturant proprement toute erreur au lieu de planter le service.
      // ---------------------------------------------------------------
 
      // Vérification du service de localisation : sûre en arrière-plan
      // (ne nécessite pas d'Activity), on la garde par sécurité.
      bool enabled = true; // on suppose activé si la vérification échoue
      try {
        enabled = await Geolocator.isLocationServiceEnabled();
      } catch (e) {
        // ✅ Si CETTE vérification lève elle aussi "Activity is missing",
        // on ne bloque pas : le foreground l'a déjà validé avant de
        // démarrer le service. On log et on continue.
        print("Impossible de vérifier le GPS (on continue) : $e");
        enabled = true;
      }
      if (!enabled) {
        print("GPS DESACTIVE");
        await _reportError(
          "Le GPS du téléphone semble désactivé. Active la localisation puis relance.",
        );
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
 
      busRef = query.docs.first.reference;
 
      await busRef.set({
        'status': 'En service',
        'tracking': true,
        'gpsError': null,
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
          'gpsError': null,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print("PREMIERE POSITION ENVOYEE");
      } catch (e) {
        print("ERREUR POSITION INITIALE : $e");
        // ✅ Si l'erreur est bien "Activity is missing" malgré tout
        // (permission jamais accordée en amont), on le signale clairement
        // au lieu de rester bloqué en silence.
        await busRef.set({
          'gpsError': _messageLisible(e),
        }, SetOptions(merge: true));
      }
 
      // Stream GPS continu
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 5,
        ),
      ).listen(
        (Position position) async {
          try {
            if (position.latitude.isNaN || position.longitude.isNaN) {
              print("POSITION INVALIDE");
              return;
            }
            await busRef!.set({
              'latitude': position.latitude,
              'longitude': position.longitude,
              'vitesse': position.speed * 3.6,
              'tracking': true,
              'gpsError': null,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          } catch (e) {
            print("ERREUR FIRESTORE : $e");
          }
        },
        onError: (e) async {
          print("ERREUR STREAM GPS : $e");
          await busRef?.set({
            'gpsError': _messageLisible(e),
          }, SetOptions(merge: true));
        },
      );
 
      service.on("stop").listen((event) async {
        await busRef!.set({
          'status': 'Disponible',
          'tracking': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        service.stopSelf();
        print("SERVICE ARRETE");
      });
    } catch (e) {
      print("ERREUR SERVICE : $e");
      await _reportError(_messageLisible(e), busRef: busRef);
    }
  }
 
  /// Transforme les erreurs techniques du plugin en message compréhensible.
  static String _messageLisible(Object e) {
    final msg = e.toString();
    if (msg.contains("Activity is missing")) {
      return "Permission de localisation non confirmée. Retourne dans l'app, "
          "appuie sur STOP puis à nouveau sur START pour relancer le GPS "
          "après avoir autorisé la localisation.";
    }
    if (msg.contains("permission") || msg.contains("Permission")) {
      return "Permission de localisation manquante ou refusée.";
    }
    return "Erreur GPS : $msg";
  }
 
  static Future<void> _reportError(
    String message, {
    DocumentReference<Map<String, dynamic>>? busRef,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final ref = busRef ??
          (user != null
              ? (await FirebaseFirestore.instance
                      .collection('buses')
                      .where('chauffeurId', isEqualTo: user.uid)
                      .limit(1)
                      .get())
                  .docs
                  .firstOrNull
                  ?.reference
              : null);
 
      await ref?.set({
        'tracking': false,
        'status': 'Disponible',
        'gpsError': message,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // On abandonne silencieusement plutôt que de planter le service.
    }
  }
}
 
