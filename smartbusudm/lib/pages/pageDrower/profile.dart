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

  String role = "user";
  String? photoUrl;
  String originalEmail = "";

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
        role = doc.data()?['role'] ?? 'user';
        photoUrl = doc.data()?['photoUrl'];
        originalEmail = emailController.text;
      }
    } catch (e) {
      debugPrint("Erreur chargement: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // 🔐 DEMANDER LE MOT DE PASSE ACTUEL (nécessaire avant email/mot de passe)
  Future<String?> askCurrentPassword() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirmation requise"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Par sécurité, entre ton mot de passe actuel.",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mot de passe actuel",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }

  Future<bool> reauthenticate(String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );
      await user!.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mot de passe incorrect: ${e.message}")),
        );
      }
      return false;
    }
  }

  // 🔒 CHANGER LE MOT DE PASSE
  Future<void> changePassword() async {
    final currentPassword = await askCurrentPassword();
    if (currentPassword == null || currentPassword.isEmpty) return;

    final ok = await reauthenticate(currentPassword);
    if (!ok) return;

    if (!mounted) return;

    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Nouveau mot de passe"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nouveau mot de passe",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirmer le mot de passe",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Valider"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Le mot de passe doit contenir au moins 6 caractères")),
        );
      }
      return;
    }
    if (newPassword != confirmPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
        );
      }
      return;
    }

    try {
      await user!.updatePassword(newPassword);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mot de passe modifié ✅")),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.message}")),
        );
      }
    }
  }

  // 🔥 UPDATE PROFIL (NOM + EMAIL)
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

    final emailChanged = emailController.text.trim() != originalEmail.trim();

    // 🔐 Si l'email change, on exige une réauthentification avant de continuer
    if (emailChanged) {
      final currentPassword = await askCurrentPassword();
      if (currentPassword == null || currentPassword.isEmpty) return;

      final ok = await reauthenticate(currentPassword);
      if (!ok) return;

      try {
        // Envoie un email de vérification au nouvel email avant de l'appliquer
        await user!.verifyBeforeUpdateEmail(emailController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Un email de confirmation a été envoyé à la nouvelle adresse ✉️"),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur changement email: ${e.message}")),
          );
        }
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'nom': nameController.text,
        'email': emailController.text,
      }, SetOptions(merge: true));

      originalEmail = emailController.text;
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

  /// 🏷️ BADGE DE RÔLE
  Widget roleBadge() {
    late String label;
    late IconData icon;
    late Color color;

    switch (role) {
      case "chauffeur":
        label = "Chauffeur";
        icon = Icons.directions_bus;
        color = Colors.orange.shade700;
        break;
      case "admin":
        label = "Administrateur";
        icon = Icons.shield;
        color = Colors.purple.shade700;
        break;
      default:
        label = "Étudiant";
        icon = Icons.school;
        color = Colors.white;
    }

    // Style spécial pour "Étudiant" (fond clair sur header bleu)
    final isDefault = role != "chauffeur" && role != "admin";

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: isDefault ? Colors.white.withOpacity(0.2) : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          // ignore: deprecated_member_use
          color: isDefault ? Colors.white70 : color.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDefault ? Colors.white : color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDefault ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
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
        child: SingleChildScrollView(
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
                    /// 📷 PHOTO DE PROFIL (lecture seule)
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl!) : null,
                      child: photoUrl == null
                          ? const Icon(Icons.person,
                              size: 60, color: Color(0xFF1565C0))
                          : null,
                    ),

                    const SizedBox(height: 15),

                    /// MODE EDIT
                    if (isEditing)
                      Column(
                        children: [
                          // NOM
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
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
                                prefixIcon: Icon(Icons.person, color: Colors.white),
                                hintText: "Nom",
                                hintStyle: TextStyle(color: Colors.white70),
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          // EMAIL
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
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
                                prefixIcon: Icon(Icons.email, color: Colors.white),
                                hintText: "Email",
                                hintStyle: TextStyle(color: Colors.white54),
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
                            style: const TextStyle(color: Colors.white70),
                          ),
                          roleBadge(),
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
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  // 🩹 Material transparent : nécessaire pour que les ListTile
                  // affichent correctement leur effet d'encre au clic
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit, color: Colors.blue),
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
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: updateProfile,
                              child: const Text(
                                "Sauvegarder",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        const Divider(),

                        ListTile(
                          leading: const Icon(Icons.lock_outline, color: Colors.blue),
                          title: const Text("Changer le mot de passe"),
                          onTap: changePassword,
                        ),

                        const Divider(),

                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
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
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}