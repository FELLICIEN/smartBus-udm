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

      final lat =
          (data['latitude'] as num?)?.toDouble();

      final lng =
          (data['longitude'] as num?)?.toDouble();

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
    final lat =
        (busData?['latitude'] as num?)?.toDouble();

    final lng =
        (busData?['longitude'] as num?)?.toDouble();

    final speed =
        (busData?['vitesse'] as num?)?.toDouble() ??
            0.0;

    final tracking =
        busData?['tracking'] ?? false;

    final status =
        busData?['status']?.toString() ??
            "Disponible";

    if (busData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          "Suivi GPS du Bus",
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(
              right: 12,
              top: 10,
              bottom: 10,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: getStatusColor(status),
              borderRadius:
                  BorderRadius.circular(20),
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
          ? Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.gps_off,
                      size: 100,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "${widget.busName}\n\nLe chauffeur n'a pas activé le GPS.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 3,
                  child: FlutterMap(
                    mapController:
                        _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        lat ??
                            widget.latitude,
                        lng ??
                            widget.longitude,
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

                      if (lat != null &&
                          lng != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                lat,
                                lng,
                              ),
                              width: 120,
                              height: 90,
                              child: Column(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal:
                                          8,
                                      vertical: 4,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: Colors
                                          .white,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  12),
                                    ),
                                    child: Text(
                                      widget
                                          .busName,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 4),

                                  const Icon(
                                    Icons
                                        .directions_bus,
                                    size: 42,
                                    color:
                                        Colors.red,
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
                  padding:
                      const EdgeInsets.all(
                          16),
                  decoration:
                      const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(
                      top: Radius.circular(
                          20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        "Bus : ${widget.busName}",
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 10),

                      Text(
                        "Statut : $status",
                        style:
                            const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        tracking
                            ? "Suivi GPS : Actif"
                            : "Suivi GPS : Arrêté",
                        style: TextStyle(
                          fontSize: 16,
                          color: tracking
                              ? Colors.green
                              : Colors.red,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 10),

                      Text(
                        "Latitude : ${lat?.toStringAsFixed(6) ?? '--'}",
                        style:
                            const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        "Longitude : ${lng?.toStringAsFixed(6) ?? '--'}",
                        style:
                            const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        "Vitesse : ${speed.toStringAsFixed(1)} km/h",
                        style:
                            const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}