import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartbusudm/pages/station/station_detaille_page.dart';

class StationPage extends StatefulWidget {
  const StationPage({super.key});

  @override
  State<StationPage> createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  String search = "";

  Stream<QuerySnapshot> getStations() {
    return FirebaseFirestore.instance
        .collection('stations')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Column(
          children: [

            /// 🔥 HEADER
            Container(
              height: 250,
              width: double.infinity,

              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bus2.png'),
                  fit: BoxFit.cover,
                ),
              ),

              child: Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.45),
                ),

                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(  
                            'assets/cnou_icon.png',
                          ),
                          
    
    ),
  ],
),
                    Spacer(),

                    /// 🚌 TITRE
                    Text(
                      "Stations",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    /// 📄 DESCRIPTION
                    Text(
                      "Clique sur une station pour voir les bus",

                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w500,
                        fontStyle:
                            FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 🔍 RECHERCHE
            Padding(
              padding: const EdgeInsets.all(15),

              child: TextField(
                onChanged: (v) {
                  setState(() {
                    search = v.toLowerCase();
                  });
                },

                decoration: InputDecoration(
                  hintText:
                      "Rechercher une station...",

                  prefixIcon:
                      const Icon(Icons.search),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding:
                      const EdgeInsets.symmetric(
                    vertical: 0,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(15),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),
            ),

            /// 🔥 STREAM STATIONS
            Expanded(
              child:
                  StreamBuilder<QuerySnapshot>(
                stream: getStations(),

                builder: (context, snapshot) {

                  /// ⏳ LOADING
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  /// ❌ ERREUR
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Erreur de chargement",
                      ),
                    );
                  }

                  /// 🚫 PAS DE DATA
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text(
                        "Aucune station",
                      ),
                    );
                  }

                  final stations =
                      snapshot.data!.docs;

                  /// 🔥 FILTRE RECHERCHE
                  final filtered = stations
                      .where((doc) {
                    final name =
                        (doc['nom'] ?? "")
                            .toString()
                            .toLowerCase();

                    return name.contains(
                        search);
                  }).toList();

                  /// 🚫 AUCUN RESULTAT
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aucune station trouvée",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [

                      /// 🔥 TOTAL STATIONS
                      Container(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),

                        padding:
                            const EdgeInsets.all(18),

                        decoration:
                            BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                                  18),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  // ignore: deprecated_member_use
                                  .withOpacity(0.08),

                              blurRadius: 10,

                              offset:
                                  const Offset(
                                0,
                                5,
                              ),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [

                            /// 🔵 ICON
                            Container(
                              padding:
                                  const EdgeInsets
                                      .all(14),

                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .blue.shade50,

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            15),
                              ),

                              child: const Icon(
                                Icons.location_city,

                                color:
                                    Colors.blue,

                                size: 30,
                              ),
                            ),

                            const SizedBox(
                                width: 15),

                            /// 📄 TEXT
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  const Text(
                                    "Nombre total des stations",

                                    style:
                                        TextStyle(
                                      fontSize:
                                          16,

                                      color:
                                          Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          5),

                                  Text(
                                    "${filtered.length} station(s)",

                                    style:
                                        const TextStyle(
                                      fontSize:
                                          26,

                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      color:
                                          Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// 🔥 LISTE
                      Expanded(
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.all(
                                  12),

                          itemCount:
                              filtered.length,

                          itemBuilder:
                              (context, index) {

                            final station =
                                filtered[index];

                            return InkWell(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          15),

                              onTap: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StationBusPage(
                                      stationId:
                                          station.id,

                                      stationName:
                                          station[
                                              'nom'],
                                    ),
                                  ),
                                );
                              },

                              child: Card(
                                elevation: 3,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              15),
                                ),

                                margin:
                                    const EdgeInsets
                                        .only(
                                  bottom: 12,
                                ),

                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets
                                          .all(12),

                                  /// 🔵 ICON
                                  leading:
                                      Container(
                                    padding:
                                        const EdgeInsets
                                            .all(
                                                10),

                                    decoration:
                                        BoxDecoration(
                                      color: Colors
                                          .blue
                                          .shade50,

                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  12),
                                    ),

                                    child:
                                        const Icon(
                                      Icons
                                          .location_on,

                                      color: Colors
                                          .blue,
                                    ),
                                  ),

                                  /// 🏷️ NOM
                                  title: Text(
                                    "Station ${station['nom']}",

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      fontSize:
                                          17,
                                    ),
                                  ),

                                  /// 📄 DESCRIPTION
                                  subtitle: Padding(
                                    padding:
                                        const EdgeInsets
                                            .only(
                                      top: 8,
                                    ),

                                    child: Text(
                                      station['description'] ??
                                          "Pas de description",
                                    ),
                                  ),

                                  /// ➡️ ADRESSE
                                  trailing:
                                      Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,

                                    children: [

                                      const Icon(
                                        Icons
                                            .arrow_forward_ios,

                                        size: 16,
                                      ),

                                      const SizedBox(
                                          height:
                                              8),

                                      SizedBox(
                                        width: 90,

                                        child:
                                            Text(
                                          station['adresse'] ??
                                              "Sans adresse",

                                          textAlign:
                                              TextAlign
                                                  .center,

                                          overflow:
                                              TextOverflow
                                                  .ellipsis,

                                          style:
                                              TextStyle(
                                            fontSize:
                                                12,

                                            color: Theme.of(
                                                    context)
                                                .primaryColor,

                                            fontWeight:
                                                FontWeight
                                                    .w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}