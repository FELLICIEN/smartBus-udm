import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartbusudm/pages/add/add_station.dart';

class StationsPage extends StatefulWidget {
  const StationsPage({super.key});

  @override
  State<StationsPage> createState() =>
      _StationsPageState();
}

class _StationsPageState
    extends State<StationsPage> {

  /// 🔍 RECHERCHE
  String search = "";

  /// 🔥 STREAM STATIONS
  Stream<QuerySnapshot> getStations() {
    return FirebaseFirestore.instance
        .collection('stations')
        .snapshots();
  }

  /// 🗑️ DELETE STATION
  Future<void> deleteStation(
      String stationId) async {

    /// 🔥 DELETE STATION
    await FirebaseFirestore.instance
        .collection('stations')
        .doc(stationId)
        .delete();

    /// 🔥 DELETE PASSAGES
    final passages =
        await FirebaseFirestore.instance
            .collection('passages')
            .where(
              'stationId',
              isEqualTo: stationId,
            )
            .get();

    for (var doc in passages.docs) {
      await doc.reference.delete();
    }
  }

  /// ✏️ UPDATE STATION
  void updateStation(
    BuildContext context,
    String stationId,
    Map<String, dynamic> station,
  ) {

    TextEditingController
        nomController =
        TextEditingController(
      text: station['nom'] ?? "",
    );

    TextEditingController
        descriptionController =
        TextEditingController(
      text:
          station['description'] ?? "",
    );

    TextEditingController
        adresseController =
        TextEditingController(
      text: station['adresse'] ?? "",
    );

    showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    20),
          ),

          title: const Text(
            "Modifier station",
          ),

          content:
              SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [

                /// 🏷️ NOM
                TextField(
                  controller:
                      nomController,

                  decoration:
                      const InputDecoration(
                    labelText:
                        "Nom station",

                    prefixIcon: Icon(
                      Icons.location_city,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 15),

                /// 📝 DESCRIPTION
                TextField(
                  controller:
                      descriptionController,

                  maxLines: 3,

                  decoration:
                      const InputDecoration(
                    labelText:
                        "Description",

                    prefixIcon: Icon(
                      Icons.description,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 15),

                /// 📍 ADRESSE
                TextField(
                  controller:
                      adresseController,

                  decoration:
                      const InputDecoration(
                    labelText:
                        "Adresse",

                    prefixIcon:
                        Icon(Icons.place),
                  ),
                ),
              ],
            ),
          ),

          actions: [

            /// ❌ ANNULER
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child:
                  const Text("Annuler"),
            ),

            /// 💾 UPDATE
            ElevatedButton(
              onPressed: () async {

                await FirebaseFirestore
                    .instance
                    .collection(
                        'stations')
                    .doc(stationId)
                    .update({

                  'nom':
                      nomController.text,

                  'description':
                      descriptionController
                          .text,

                  'adresse':
                      adresseController
                          .text,
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Station mise à jour avec succès !",
                    ),

                    backgroundColor:
                        Color(
                            0xFF4CAF50),
                  ),
                );
              },

              child:
                  const Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  /// 🔍 DETAILS
  void showDetails(
    BuildContext context,
    String stationId,
    Map<String, dynamic> station,
  ) {

    showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    20),
          ),

          title: Text(
            station['nom'] ?? "",
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [

              const Icon(
                Icons.location_on,
                size: 70,
                color: Colors.blue,
              ),

              const SizedBox(height: 15),

              Text(
                station['description'] ??
                    "",
              ),

              const SizedBox(height: 10),

              Text(
                "📍 ${station['adresse'] ?? ""}",
              ),
            ],
          ),

          actions: [

            /// 🗑️ DELETE
            TextButton.icon(
              onPressed: () async {

                Navigator.pop(context);

                await deleteStation(
                    stationId);

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Station supprimée avec succès !",
                    ),

                    backgroundColor:
                        Colors.red,
                  ),
                );
              },

              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),

              label: const Text(
                "Supprimer",

                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),

            /// ✏️ UPDATE
            ElevatedButton.icon(
              onPressed: () {

                Navigator.pop(context);

                updateStation(
                  context,
                  stationId,
                  station,
                );
              },

              icon:
                  const Icon(Icons.edit),

              label:
                  const Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FA),

      appBar: AppBar(
        backgroundColor:
            Colors.blue,

        centerTitle: true,

        title: const Text(
          "Gestion des stations",

          style: TextStyle(
            fontSize: 26,
            fontWeight:
                FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body:
          StreamBuilder<QuerySnapshot>(
        stream: getStations(),

        builder:
            (context, snapshot) {

          /// ⏳ LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          /// ❌ ERROR
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erreur : ${snapshot.error}",
              ),
            );
          }

          /// 🚫 EMPTY
          if (!snapshot.hasData ||
              snapshot.data!.docs
                  .isEmpty) {
            return const Center(
              child: Text(
                "Aucune station disponible 🚫",
              ),
            );
          }

          final stations =
              snapshot.data!.docs;

          /// 🔥 FILTRE
          final filteredStations =
              stations.where((doc) {

            final data =
                doc.data()
                    as Map<String,
                        dynamic>;

            final nom =
                (data['nom'] ?? "")
                    .toString()
                    .toLowerCase();

            return nom.contains(
              search.toLowerCase(),
            );
          }).toList();

          return Column(
            children: [

              /// 🔍 SEARCH
              Padding(
                padding:
                    const EdgeInsets.all(
                        15),

                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      search = value;
                    });
                  },

                  decoration:
                      InputDecoration(
                    hintText:
                        "Rechercher une station...",

                    prefixIcon:
                        const Icon(
                      Icons.search,
                    ),

                    filled: true,
                    fillColor:
                        Colors.white,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  15),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),
              ),

              /// 🔥 TOTAL
              Container(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 15,
                ),

                padding:
                    const EdgeInsets.all(
                        18),

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
                          .withOpacity(
                              0.05),

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

                    Container(
                      padding:
                          const EdgeInsets
                              .all(14),

                      decoration:
                          BoxDecoration(
                        color: Colors
                            .blue
                            .shade50,

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
                              height: 5),

                          Text(
                            "${filteredStations.length} station(s)",

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
                          15),

                  itemCount:
                      filteredStations
                          .length,

                  itemBuilder:
                      (context, index) {

                    final station =
                        filteredStations[
                            index];

                    final data =
                        station.data()
                            as Map<String,
                                dynamic>;

                    final stationId =
                        station.id;

                    return InkWell(
                      onTap: () {
                        showDetails(
                          context,
                          stationId,
                          data,
                        );
                      },

                      borderRadius:
                          BorderRadius
                              .circular(
                                  18),

                      child: Container(
                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 15,
                        ),

                        padding:
                            const EdgeInsets
                                .all(16),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      18),

                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .black
                                  // ignore: deprecated_member_use
                                  .withOpacity(
                                      0.05),

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
                                      .all(
                                          14),

                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .blue
                                    // ignore: deprecated_member_use
                                    .withOpacity(
                                        0.1),

                                shape: BoxShape
                                    .circle,
                              ),

                              child:
                                  const Icon(
                                Icons
                                    .location_on,

                                color: Colors
                                    .blue,
                              ),
                            ),

                            const SizedBox(
                                width: 15),

                            /// 📄 INFOS
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(
                                    "Station ${data['nom'] ?? ""}",

                                    style:
                                        const TextStyle(
                                      fontSize:
                                          18,

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          5),

                                  Text(
                                    data['description'] ??
                                        "",

                                    maxLines:
                                        2,

                                    overflow:
                                        TextOverflow
                                            .ellipsis,

                                    style:
                                        TextStyle(
                                      color: Colors
                                              .grey[
                                          700],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// ➡️
                            Column(
                              children: [

                                const Icon(
                                  Icons
                                      .arrow_forward_ios,

                                  size: 16,

                                  color:
                                      Colors
                                          .grey,
                                ),

                                const SizedBox(
                                    height:
                                        10),

                                Text(
                                  "📍 ${data['adresse'] ?? ""}",

                                  style:
                                      TextStyle(
                                    color: Theme.of(
                                            context)
                                        .primaryColor,

                                    fontSize:
                                        13,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
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

      /// 🔥 BOTTOM NAVIGATION
      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: 0,

        backgroundColor:
            Theme.of(context)
                .primaryColor,

        selectedItemColor:
            Colors.white,

        unselectedItemColor:
            Colors.white70,

        onTap: (index) {

          /// ➕ AJOUT
          if (index == 1) {
            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                    const AddStationPage(),
              ),
            );
          }
        },

        items: const [

          BottomNavigationBarItem(
            icon:
                Icon(Icons.location_on),

            label: "Stations",
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.add_circle),

            label: "Ajouter",
          ),
        ],
      ),
    );
  }
}