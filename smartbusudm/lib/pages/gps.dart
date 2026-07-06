import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Gps extends StatefulWidget {
  final String busId;
  final String busName;
  final double longitude;
  final double latitude;

  const Gps({
    super.key,
    required this.busId,
    required this.busName,
    required this.longitude,
    required this.latitude,
  });

  @override
  State<Gps> createState() => _GpsState();
}

class _GpsState extends State<Gps> {
  final MapController _mapController = MapController();

  Map<String, dynamic>? busData;
  bool _firstCenterDone = false;

  @override
  void initState() {
    super.initState();
    _listenBus();
  }

  void _listenBus() {
    FirebaseFirestore.instance
        .collection('buses')
        .doc(widget.busId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final data = doc.data();
      if (data == null) return;

      setState(() {
        busData = data;
      });

      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();

      if (lat != null && lng != null && mounted) {
        _mapController.move(LatLng(lat, lng), _firstCenterDone ? _mapController.camera.zoom : 16);
        _firstCenterDone = true;
      }
    });
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "disponible":
        return Colors.green;
      case "en service":
        return Colors.orange;
      case "en panne":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = (busData?['latitude'] as num?)?.toDouble();
    final lng = (busData?['longitude'] as num?)?.toDouble();
    final speed = (busData?['vitesse'] as num?)?.toDouble() ?? 0.0;
    final tracking = busData?['tracking'] ?? false;
    final status = busData?['status']?.toString() ?? "Disponible";
    final gpsError = busData?['gpsError']?.toString();
    final hasPosition = lat != null && lng != null;

    if (busData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Suivi GPS du Bus"),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: getStatusColor(status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: !tracking
          ? _buildMessageState(
              icon: Icons.gps_off,
              iconColor: Colors.red,
              title: widget.busName,
              message: gpsError ?? "Le chauffeur n'a pas activé le GPS.",
            )
          : !hasPosition
              ? _buildMessageState(
                  icon: Icons.satellite_alt_outlined,
                  iconColor: Colors.orange,
                  title: widget.busName,
                  message: gpsError ??
                      "En attente du signal GPS du chauffeur...\nCela peut prendre quelques secondes.",
                  showSpinner: gpsError == null,
                )
              : Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(lat, lng),
                          initialZoom: 16,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.smartbusudm',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(lat, lng),
                                width: 130,
                                height: 90,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                // ignore: deprecated_member_use
                                                .withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        "Bus ${widget.busName}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.directions_bus,
                                        size: 28,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bus : ${widget.busName}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Statut : $status",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            tracking ? "Suivi GPS : Actif" : "Suivi GPS : Arrêté",
                            style: TextStyle(
                              fontSize: 16,
                              color: tracking ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Latitude : ${lat.toStringAsFixed(6)}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Longitude : ${lng.toStringAsFixed(6)}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Vitesse : ${speed.toStringAsFixed(1)} km/h",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    bool showSpinner = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showSpinner)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: CircularProgressIndicator(),
              )
            else
              Icon(icon, size: 90, color: iconColor),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
