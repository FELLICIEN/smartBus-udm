import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Gps extends StatefulWidget {
  final String busId;
  final String busName;
  final String busStatus;

  const Gps({
    super.key,
    required this.busId,
    required this.busName,
    required this.busStatus,
  });

  @override
  State<Gps> createState() => _GpsState();
}

class _GpsState extends State<Gps> {
  final MapController _mapController = MapController();

  Map<String, dynamic>? busData;

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
        _mapController.move(
          LatLng(lat, lng),
          16,
        );
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
    final speed =
        (busData?['vitesse'] as num?)?.toDouble() ?? 0.0;

    final status =
        busData?['status']?.toString() ?? widget.busStatus;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Suivi GPS du Bus",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: getStatusColor(status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                widget.busName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: busData == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  flex: 3,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        lat ?? 12.1348,
                        lng ?? 15.0557,
                      ),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.smartbusudm',
                      ),

                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              lat ?? 12.1348,
                              lng ?? 15.0557,
                            ),
                            width: 120,
                            height: 80,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 4,
                                        color: Colors.black26,
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    widget.busName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Icon(
                                  Icons.directions_bus,
                                  size: 40,
                                  color: Colors.red,
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bus : ${widget.busName}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Statut : $status",
                        style: const TextStyle(fontSize: 16),
                      ),

                      Text(
                        "Latitude : ${lat?.toStringAsFixed(6) ?? '--'}",
                        style: const TextStyle(fontSize: 16),
                      ),

                      Text(
                        "Longitude : ${lng?.toStringAsFixed(6) ?? '--'}",
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
}
