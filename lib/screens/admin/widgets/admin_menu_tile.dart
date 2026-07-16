import 'package:flutter/material.dart';

class AdminMenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const AdminMenuTile({
    super.key,

    required this.title,

    required this.icon,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),

        title: Text(title),

        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: onTap,
      ),
    );
  }
}
