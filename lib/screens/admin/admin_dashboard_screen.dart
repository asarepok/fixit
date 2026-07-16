import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_mode_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/verification_provider.dart';
import '../../models/booking_model.dart';
import 'manage_artisans_screen.dart';
import 'manage_bookings_screen.dart';
import 'manage_payments_screen.dart';
import 'manage_users_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();
    ref.read(appModeProvider.notifier).state = AppMode.customer;
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);
    final users = ref.watch(allUsersProvider).valueOrNull;
    final applications = ref.watch(pendingApplicationsProvider).valueOrNull;
    final bookings = ref.watch(allBookingsProvider).valueOrNull;
    final activeBookings = bookings
        ?.where(
          (booking) =>
              booking.status == BookingStatus.pending ||
              booking.status == BookingStatus.accepted ||
              booking.status == BookingStatus.inProgress,
        )
        .length;
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
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
            actions: [
              IconButton(
                tooltip: 'Log out',
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => _logout(context, ref),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, _) {
                  return GridView.extent(
                    maxCrossAxisExtent: 220,
                    mainAxisExtent: 142,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _AdminMetric(
                        label: 'Total users',
                        icon: Icons.people_outline,
                        value: users?.length.toString() ?? '—',
                      ),
                      _AdminMetric(
                        label: 'Verified artisans',
                        icon: Icons.handyman_outlined,
                        value:
                            users
                                ?.where((user) => user.isArtisan)
                                .length
                                .toString() ??
                            '—',
                      ),
                      _AdminMetric(
                        label: 'Pending applications',
                        icon: Icons.pending_actions_outlined,
                        value: applications?.length.toString() ?? '—',
                      ),
                      _AdminMetric(
                        label: 'Active bookings',
                        icon: Icons.calendar_month_outlined,
                        value: activeBookings?.toString() ?? '—',
                      ),
                    ],
                  );
                },
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
                icon: Icons.account_balance_wallet_outlined,
                title: 'Manage Payments',
                subtitle: 'Review escrow and refunds',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManagePaymentsScreen(),
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
                'Pull down to refresh the latest management data.',
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
  const _AdminMetric({
    required this.label,
    required this.icon,
    required this.value,
  });
  final String label;
  final IconData icon;
  final String value;
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
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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
