import 'package:flutter/material.dart';
import 'package:smartbusudm/pages/regist_login/login_page.dart';
import 'package:smartbusudm/pages/second_page.dart';
import 'package:smartbusudm/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool obscure = true;

  void register() async {
    final nom = nomController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (nom.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage("Veuillez remplir tous les champs");
      return;
    }

    if (!email.contains("@")) {
      showMessage("Email invalide");
      return;
    }

    if (password != confirmPassword) {
      showMessage("Les mots de passe ne correspondent pas");
      return;
    }

    if (password.length < 6) {
      showMessage("Mot de passe trop court (min 6 caractères)");
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService().registerUser(
        nom: nom,
        email: email,
        password: password,
      );

      showMessage("Inscription réussie ✅");

      // Navigation optionnelle
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const SecondePage()),
    );

    } catch (e) {
      showMessage(e.toString().replaceAll("Exception: ", ""));
    }

    setState(() => isLoading = false);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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

            const SizedBox(height: 25),

            Text(
              "Inscription",
              style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: "BoostPlay",
                      color: Theme.of(context).primaryColor,
                    ),
            ),

            const SizedBox(height: 20),

            /// 🧾 FORMULAIRE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  /// NOM
                  TextField(
                    controller: nomController,
                    decoration: inputStyle("Nom complet", Icons.person),
                  ),

                  const SizedBox(height: 12),

                  /// EMAIL
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputStyle("Email", Icons.email),
                  ),

                  const SizedBox(height: 12),

                  /// PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: inputStyle("Mot de passe", Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscure = !obscure;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// CONFIRM PASSWORD
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: inputStyle(
                      "Confirmer mot de passe",
                      Icons.lock_outline,
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// LOADING
                  if (isLoading) const CircularProgressIndicator(),

                  const SizedBox(height: 10),

                  /// BUTTON
                  ElevatedButton(
                    onPressed: isLoading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "S'inscrire",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Connexion(),
                        ),
                      );
                    },
                    

                    child: const Text("Déjà un compte ?"),
                  ),
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
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 1.5,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 2.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }
}