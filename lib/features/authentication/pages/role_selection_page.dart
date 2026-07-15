import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  Widget buildCard(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.go('/home');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Your Role"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildCard(
              context,
              Icons.person,
              "Customer",
              "Hire skilled artisans",
            ),

            const SizedBox(height: 20),

            buildCard(
              context,
              Icons.handyman,
              "Artisan",
              "Provide services and earn",
            ),
          ],
        ),
      ),
    );
  }
}