import 'package:flutter/material.dart';

import '../../../models/user_model.dart';

class AdminGuard extends StatelessWidget {
  final UserModel user;
  final Widget child;

  const AdminGuard({super.key, required this.user, required this.child});

  @override
  Widget build(BuildContext context) {
    if (user.isAdmin) {
      return child;
    }

    return const Scaffold(
      body: Center(
        child: Text("Access Denied", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
