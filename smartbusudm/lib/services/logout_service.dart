





import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartbusudm/pages/regist_login/login_page.dart';
Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  if (!context.mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const Connexion()),
    (route) => false,
  );
}







void confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      
      
      title: const Text("Déconnexion"),
      content: const Text("Voulez-vous vraiment vous déconnecter ?"),
      
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            logout(context);
            scaffoldMessengerOf(context).showSnackBar(
              const SnackBar(content: Text("Déconnexion réussie ✅"),
              duration: Duration(seconds: 2 ),),
            );  
          },
          child: const Text("Oui"),
        ),
      ],
    ),
  );
}

scaffoldMessengerOf(BuildContext context) {
  return ScaffoldMessenger.of(context);

}