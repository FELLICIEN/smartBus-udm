import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Gps extends StatefulWidget {
  final String busId;
  final String busName;
<<<<<<< HEAD
  final String busStatus;
=======
  final double longitude;
  final double latitude;
>>>>>>> 006c8ba (depot1)

  const Gps({
    super.key,
    required this.busId,
    required this.busName,
<<<<<<< HEAD
    required this.busStatus,
=======
    required this.longitude,
    required this.latitude,
>>>>>>> 006c8ba (depot1)
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

<<<<<<< HEAD
      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();
=======
      final lat =
          (data['latitude'] as num?)?.toDouble();

      final lng =
          (data['longitude'] as num?)?.toDouble();
>>>>>>> 006c8ba (depot1)

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
<<<<<<< HEAD
    final lat = (busData?['latitude'] as num?)?.toDouble();
    final lng = (busData?['longitude'] as num?)?.toDouble();
    final speed =
        (busData?['vitesse'] as num?)?.toDouble() ?? 0.0;

    final status =
        busData?['status']?.toString() ?? widget.busStatus;
=======
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
>>>>>>> 006c8ba (depot1)

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
<<<<<<< HEAD
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
=======
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
>>>>>>> 006c8ba (depot1)
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
<<<<<<< HEAD
      body: busData == null
          ? const Center(
              child: CircularProgressIndicator(),
=======

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
>>>>>>> 006c8ba (depot1)
            )
          : Column(
              children: [
                Expanded(
                  flex: 3,
                  child: FlutterMap(
<<<<<<< HEAD
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        lat ?? 12.1348,
                        lng ?? 15.0557,
=======
                    mapController:
                        _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        lat ??
                            widget.latitude,
                        lng ??
                            widget.longitude,
>>>>>>> 006c8ba (depot1)
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

<<<<<<< HEAD
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
=======
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
>>>>>>> 006c8ba (depot1)
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
<<<<<<< HEAD
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
=======
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
>>>>>>> 006c8ba (depot1)
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
<<<<<<< HEAD
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
=======
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
>>>>>>> 006c8ba (depot1)
                      ),

                      Text(
                        "Longitude : ${lng?.toStringAsFixed(6) ?? '--'}",
<<<<<<< HEAD
                        style: const TextStyle(fontSize: 16),
=======
                        style:
                            const TextStyle(
                          fontSize: 16,
                        ),
>>>>>>> 006c8ba (depot1)
                      ),

                      Text(
                        "Vitesse : ${speed.toStringAsFixed(1)} km/h",
<<<<<<< HEAD
                        style: const TextStyle(fontSize: 16),
=======
                        style:
                            const TextStyle(
                          fontSize: 16,
                        ),
>>>>>>> 006c8ba (depot1)
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
