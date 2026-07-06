import 'package:flutter/material.dart';

class PolitiqueConfidentialitePage extends StatelessWidget {
  const PolitiqueConfidentialitePage({super.key});

  Widget buildSection(IconData icon, String title, String content) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 178, 187, 223),

        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              
              
              shape: BoxShape.circle,
            ),
            child: Icon(icon,size: 40, color: const Color.fromARGB(255, 7, 66, 168)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "politique",
      child: Scaffold(
        
        backgroundColor: const Color(0xFFF5F6FA),
      
        appBar: AppBar(
          elevation: 0,
          backgroundColor:Theme.of(context).primaryColor,
          centerTitle: true,
          title:  Text(
            "Politique de confidentialité",
              style: TextStyle(
        
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'serif',
          ),
          ),
        ),
      
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
        
            /// LOGO + TITRE
            Column(
              children: const [
                CircleAvatar(
                  backgroundImage: AssetImage("assets/udm.png"),
                  radius: 45,
                ),
                SizedBox(height: 10),
                Text(
                  "SmartBus UDM",
                  style: TextStyle(
                    fontFamily: 'Boostplay',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
        
            const SizedBox(height: 20),
        
            /// 📦 SECTIONS
            buildSection(
              Icons.info_outlined,
              "Introduction",
              "Bienvenue sur SmartBus UDM. Nous protégeons vos données personnelles et votre vie privée.",
            ),
        
            buildSection(
              Icons.person,
              "Informations collectées",
              "Nom, email, localisation, informations sur l’appareil et données d’utilisation.",
            ),
        
            buildSection(
              Icons.settings,
              "Utilisation des données",
              "Amélioration de l’application, gestion des comptes et affichage des trajets.",
            ),
        
            buildSection(
              Icons.share,
              "Partage des données",
              "Nous ne vendons pas vos données. Elles peuvent être partagées avec des services techniques.",
            ),
        
            buildSection(
              Icons.security,
              "Sécurité des données",
              "Nous protégeons vos informations contre les accès non autorisés.",
            ),
        
            buildSection(
              Icons.access_time,
              "Conservation des données",
              "Les données sont conservées uniquement pendant la durée nécessaire.",
            ),
        
            buildSection(
              Icons.lock,
              "Vos droits",
              "Vous pouvez accéder, modifier ou supprimer vos données à tout moment.",
            ),
        
            buildSection(
              Icons.location_on,
              "Localisation",
              "Utilisée pour afficher les stations proches et optimiser les trajets.",
            ),
        
            buildSection(
              Icons.update,
              "Modifications",
              "Cette politique peut être mise à jour à tout moment.",
            ),
        
            buildSection(
              Icons.email,
              "Contact",
              "support@smartbusudm.com",
            ),
        
            const SizedBox(height: 20),
        
            /// 📍 FOOTER
            Column(
              children: const [
                Icon(Icons.verified, color: Colors.green),
                SizedBox(height: 5),
                Text(
                  "Vos données sont protégées",
                  style: TextStyle(color: Colors.grey),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}