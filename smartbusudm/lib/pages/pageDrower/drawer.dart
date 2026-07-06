import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartbusudm/pages/pageDrower/apropos.dart';
import 'package:smartbusudm/pages/pageDrower/chat_page.dart';
import 'package:smartbusudm/pages/pageDrower/helppage.dart';
import 'package:smartbusudm/pages/pageDrower/parametre.dart';
import 'package:smartbusudm/pages/pageDrower/politique.dart';
import 'package:smartbusudm/services/logout_service.dart';
import 'package:smartbusudm/services/message_service.dart';
 
class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});
 
  @override
  State<DrawerPage> createState() => _DrawerPageState();
}
 
class _DrawerPageState extends State<DrawerPage> {
  final messageService = MessageService();
 
  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
 
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
 
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 10,
      child: Column(
        children: [
 
          /// 🔥 HEADER BLEU ARRONDI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
 
                /// 🏫 LOGOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/udm.png',
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/cnou_icon.png',
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                  ],
                ),
 
                const SizedBox(height: 18),
 
                /// 🏷️ TITRE
                const Text(
                  "SmartBus",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
 
                const SizedBox(height: 8),
 
                /// 📄 SOUS-TITRE PILL
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Navigation intelligente ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text("🚌", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
 
          const SizedBox(height: 15),
 
          /// 🔥 ITEMS MENU (défilable pour éviter le dépassement sur petits écrans)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildItem(
                          context,
                          icon: Icons.chat_bubble_outline_rounded,
                          label: "ChatSmartBus",
                          page: const ChatPage(),
                          unreadStream: uid != null
                              ? messageService.getUnreadCount(uid)
                              : null,
                        ),
                        _buildItem(
                          context,
                          icon: Icons.settings,
                          label: "Paramètres",
                          page: Parametres(),
                        ),
                        _buildItem(
                          context,
                          icon: Icons.help_outline_rounded,
                          label: "Aide",
                          page: HelpPage(),
                        ),
                        _buildItem(
                          context,
                          icon: Icons.policy_outlined,
                          label: "Politique",
                          page: PolitiqueConfidentialitePage(),
                        ),
                        _buildItem(
                          context,
                          icon: Icons.info_outline_rounded,
                          label: "À propos",
                          page: AproposPage(),
                        ),
                      ],
                    ),
                  ),
 
                  /// 🔴 DÉCONNEXION (fixe en bas, hors du défilement)
                  GestureDetector(
                    onTap: () {
                      confirmLogout(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Déconnexion",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
 
                  /// 📄 VERSION
                  const Divider(height: 1),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Version 1.0.0",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget page,
    Stream<int>? unreadStream,
  }) {
    return GestureDetector(
      onTap: () => _navigate(context, page),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
 
            /// 🔵 ICON (+ badge non-lus si fourni)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                if (unreadStream != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: StreamBuilder<int>(
                      stream: unreadStream,
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        if (count == 0) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          constraints: const BoxConstraints(minWidth: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            count > 99 ? "99+" : "$count",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
 
            const SizedBox(width: 15),
 
            /// 🏷️ LABEL
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
 
            /// ➡️ FLECHE
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
