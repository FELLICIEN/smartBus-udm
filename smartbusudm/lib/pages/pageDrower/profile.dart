import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartbusudm/services/logout_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool isEditing = false;
  bool isLoading = true;

  // 🔥 Charger données Firestore
  Future<void> loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        nameController.text = doc['nom'] ?? '';
        emailController.text = doc['email'] ?? '';
      }
    } catch (e) {
      debugPrint("Erreur chargement: $e");
    }

    setState(() => isLoading = false);
  }

  // 🔥 Update Firestore
 Future<void> updateProfile() async {
  if (nameController.text.isEmpty || emailController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tous les champs sont requis")),
    );
    return;
  }
  if (!emailController.text.contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email invalide")),
    );
    return;
  }
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .set({
      'nom': nameController.text,
      'email': emailController.text,
    }, SetOptions(merge: true)); // ✅ IMPORTANT

    setState(() => isEditing = false);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil mis à jour ✅")),
    );
  } catch (e) {
   

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur: $e")),
    );
  }
}

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 60, color: Color(0xFF1565C0)),
                  ),

                  const SizedBox(height: 15),

                  /// MODE EDIT
                  if (isEditing)
                    Column(
                      children: [
                        // NOM
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 5),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: nameController,
                            textAlign: TextAlign.center,
                            cursorColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.white),
                              hintText: "Nom",
                              hintStyle:
                                  TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        // EMAIL
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 5),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: emailController,
                            textAlign: TextAlign.center,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white70),
                            decoration: const InputDecoration(
                              prefixIcon:
                                  Icon(Icons.email, color: Colors.white),
                              hintText: "Email",
                              hintStyle:
                                  TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    )

                  /// MODE NORMAL
                  else
                    Column(
                      children: [
                        Text(
                          nameController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          emailController.text,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.edit, color: Colors.blue),
                      title: const Text("Modifier le profil"),
                      onTap: () {
                        setState(() => isEditing = true);
                      },
                    ),

                    if (isEditing)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize:
                                const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: updateProfile,
                          child: const Text("Sauvegarder",
                              style: TextStyle(fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,)  ,
                              
                             ),
                        ),
                      ),

                    const Divider(),

                    ListTile(
                      leading:
                          const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        "Déconnexion",
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        confirmLogout(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}