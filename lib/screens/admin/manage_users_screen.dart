import 'package:flutter/material.dart';
import 'manage_artisans_screen.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdminEmptyScreen(
    title: 'Manage Users',
    icon: Icons.people_outline,
    message: 'User accounts will appear here for oversight.',
  );
}
