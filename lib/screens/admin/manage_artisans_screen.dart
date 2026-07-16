import 'package:flutter/material.dart';

class ManageArtisansScreen extends StatelessWidget {
  const ManageArtisansScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdminEmptyScreen(
    title: 'Manage Artisans',
    icon: Icons.handyman_outlined,
    message: 'Pending applications will appear here for review.',
  );
}

class AdminEmptyScreen extends StatelessWidget {
  const AdminEmptyScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });
  final String title;
  final IconData icon;
  final String message;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );
}
