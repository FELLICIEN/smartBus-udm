import 'package:flutter/material.dart';
import 'package:smartbusudm/models/user_model.dart';
import 'package:smartbusudm/services/user_service.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final searchController = TextEditingController();
  String search = "";

  @override
  Widget build(BuildContext context) {
    final service = UserService();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Utilisateurs de smartBus",
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
          fontFamily: "BoostPlay",
        ),  ),
        backgroundColor: Colors.blue,
      ) ,
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [

          /// 🔵 HEADER (comme login)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              children: const [
                SizedBox(height: 40),
                Icon(Icons.people, size: 70, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "Gestion des utilisateurs",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// 🔎 SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() => search = value);
              },
              decoration: InputDecoration(
                hintText: "Rechercher...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// STREAM USERS
          Expanded(
            child: StreamBuilder<List<AppUser>>(
              stream: service.getUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!;

                /// FILTER
                if (search.isNotEmpty) {
                  users = users.where((u) {
                    return u.nom.toLowerCase().contains(search.toLowerCase()) ||
                        u.email.toLowerCase().contains(search.toLowerCase());
                  }).toList();
                }

                return Column(
                  children: [

                    /// 📊 TOTAL CARD
                    Container(
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total utilisateurs",
                            style: TextStyle(color: Colors.white,
                                fontSize: 16,
                                
                            ),
                          ),
                          Text(
                            "${users.length}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 📋 LIST
                    Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                )
                              ],
                            ),
                            child: Row(
                              children: [

                                /// 👤 AVATAR
                                CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    user.nom.isNotEmpty
                                        ? user.nom[0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                /// INFOS
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.nom,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        user.email,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),

                                /// ROLE
                                DropdownButton<String>(
                                  value: user.role,
                                  underline: const SizedBox(),
                                  items: const [
                                    DropdownMenuItem(
                                        value: "user", child: Text("user")),
                                        DropdownMenuItem(
                                        value: "chauffeur", child: Text("chauffeur")),
                                    DropdownMenuItem(
                                        value: "admin", child: Text("admin")),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      service.updateRole(user.uid, value);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Rôle mis à jour"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                ),

                                /// DELETE
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    service.deleteUser(user.uid);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Utilisateur supprimé"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              ],
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
    );
  }
}