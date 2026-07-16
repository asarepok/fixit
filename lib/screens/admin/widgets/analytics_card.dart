import 'package:flutter/material.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const AnalyticsCard({
    super.key,

    required this.title,

    required this.value,

    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),

          child: Column(
            children: [
              Icon(icon, size: 35),

              const SizedBox(height: 10),

              Text(
                value,

                style: const TextStyle(
                  fontSize: 22,

                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
