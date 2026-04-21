
import 'package:flutter/material.dart';


class BusCard extends StatelessWidget {
  final String busNumber;
  final String status;
  final Color color;

  const BusCard({
    super.key,
    required this.busNumber,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [

          // 🚌 ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.directions_bus, size: 40, color: Colors.blue),
          ),

          const SizedBox(width: 15),

          // 📄 INFOS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  busNumber,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ⏱️ TEMPS
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                "Arrive dans",
                style: TextStyle(fontSize: 12),
              ),
              Text(
                "8 min",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Icon(Icons.arrow_forward_ios, size: 14)
            ],
          )
        ],
      ),
    );
  }
}