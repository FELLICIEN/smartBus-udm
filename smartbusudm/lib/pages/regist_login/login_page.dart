import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartbusudm/pages/regist_login/register_page.dart';
import 'package:smartbusudm/pages/second_page.dart';

/// 🎬 ANIMATION ROUTE
Route createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.8, 0.2);
      const end = Offset.zero;

      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeInOut));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}





class _ConnexionState extends State<Connexion> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerMdp = TextEditingController();

  bool obscure = true;
  bool loading = false;
  String error = "";

  /// 🔐 LOGIN FIREBASE
 Future<void> login() async {
  String email = controllerEmail.text.trim();
  String mdp = controllerMdp.text.trim();

  if (email.isEmpty || mdp.isEmpty) {
    setState(() {
      error = "Veuillez remplir tous les champs";
    });
    return;
  }

  setState(() {
    loading = true;
    error = "";
  });

  try {
    /// 🔐 FIREBASE LOGIN
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: mdp,
    );

    /// ✅ USER EXISTE
    if (userCredential.user != null) {
      if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connexion réussie",style: TextStyle(backgroundColor: Colors.green),)),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const SecondePage(),
        ),
        (route) => false,
      );
    }
  } on FirebaseAuthException catch (e) {
    String message = "";

    switch (e.code) {
      case 'user-not-found':
        message = "Utilisateur introuvable";
        break;

      case 'wrong-password':
        message = "Mot de passe incorrect";
        break;

      case 'invalid-email':
        message = "Email invalide";
        break;

      case 'invalid-credential':
        message = "Email ou mot de passe incorrect";
        break;

      default:
        message = e.message ?? "Erreur de connexion";
    }

    if (!mounted) return;

    setState(() {
      error = message;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      error = "Une erreur est survenue";
    });
  } finally {
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}


  
  @override
  void dispose() {
    controllerEmail.dispose();
    controllerMdp.dispose();
    super.dispose();
  }
snackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔵 HEADER
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
                children: [

                  const SizedBox(height: 30),

                  /// IMAGE
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage("assets/bus1.png"),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black26,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "SmartBus ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontFamily: "BoostPlay",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 🧾 FORMULAIRE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  Text(
                    "Connexion",
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: "BoostPlay",
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// EMAIL
                  TextField(
                    controller: controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputStyle("Email", Icons.email),
                  ),

                  const SizedBox(height: 15),

                  /// PASSWORD
                  TextField(
                    controller: controllerMdp,
                    obscureText: obscure,
                    decoration: inputStyle("Mot de passe", Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => obscure = !obscure);
                        },
                      ),
                    ),
                  ),

                  /// ❌ ERROR
                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        error,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 25),

                  /// BUTTON LOGIN
                  ElevatedButton(
                    onPressed: loading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Se connecter",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),

                  const SizedBox(height: 10),

                  /// LINK INSCRIPTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Pas de compte ? "),
                      TextButton(
                        
                        onPressed: () {
         
                          Navigator.push(
                            context,
                            createRoute(const RegisterPage()),
                          );
                        },
                        child: Text(
                          "S'inscrire",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 STYLE INPUT
  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}