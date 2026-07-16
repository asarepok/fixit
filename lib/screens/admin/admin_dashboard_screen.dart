import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import 'manage_artisans_screen.dart';
import 'manage_bookings_screen.dart';
import 'manage_users_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);
    return profile.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text(error.toString()))),
      data: (user) {
        if (user?.isAdmin != true) {
          return const Scaffold(body: Center(child: Text('Access denied')));
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Admin Dashboard')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: const [
                  _AdminMetric(
                    label: 'Total users',
                    icon: Icons.people_outline,
                  ),
                  _AdminMetric(
                    label: 'Verified artisans',
                    icon: Icons.handyman_outlined,
                  ),
                  _AdminMetric(
                    label: 'Pending applications',
                    icon: Icons.pending_actions_outlined,
                  ),
                  _AdminMetric(
                    label: 'Active bookings',
                    icon: Icons.calendar_month_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Management', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              _ManagementTile(
                icon: Icons.handyman_outlined,
                title: 'Manage Artisans',
                subtitle: 'Review artisan applications',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageArtisansScreen(),
                  ),
                ),
              ),
              _ManagementTile(
                icon: Icons.people_outline,
                title: 'Manage Users',
                subtitle: 'View account records',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
                ),
              ),
              _ManagementTile(
                icon: Icons.calendar_month_outlined,
                title: 'Manage Bookings',
                subtitle: 'Monitor service activity',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageBookingsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Live admin counts and actions will populate once the admin and verification providers are connected.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminMetric extends StatelessWidget {
  const _AdminMetric({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text('—', style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}

class _ManagementTile extends StatelessWidget {
  const _ManagementTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
