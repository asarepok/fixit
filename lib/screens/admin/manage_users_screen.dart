import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (items) => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final user = items[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    user.name.isEmpty ? 'U' : user.name[0].toUpperCase(),
                  ),
                ),
                title: Text(user.name.isEmpty ? 'Unnamed user' : user.name),
                subtitle: Text(user.email),
                trailing: Chip(
                  label: Text(
                    user.isAdmin
                        ? 'Admin'
                        : user.isArtisan
                        ? 'Artisan'
                        : 'Customer',
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
