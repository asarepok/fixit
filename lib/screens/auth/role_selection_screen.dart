import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/auth_provider.dart';

// Shown right after registering, so a new user can pick "customer" or
// "artisan". Saving the choice happens in AuthController.selectRole, this
// screen only reads which uid is signed in through that same provider
// rather than reading FirebaseAuth directly.
class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  Future<void> selectRole(
    BuildContext context,
    WidgetRef ref,
    String role,
  ) async {
    await ref.read(authControllerProvider.notifier).selectRole(role);

    if (context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  Widget buildCard(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String title,
    String role,
    String subtitle,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          selectRole(context, ref, role);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              ref,
              Icons.person,
              "Customer",
              "customer",
              "Hire skilled artisans",
            ),

            const SizedBox(height: 20),

            buildCard(
              context,
              ref,
              Icons.handyman,
              "Artisan",
              "artisan",
              "Provide services and earn",
            ),
          ],
        ),
      ),
    );
  }
}
