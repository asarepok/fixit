import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_mode_provider.dart';

class ArtisanDashboardScreen extends ConsumerStatefulWidget {
  const ArtisanDashboardScreen({super.key});
  @override
  ConsumerState<ArtisanDashboardScreen> createState() =>
      _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState
    extends ConsumerState<ArtisanDashboardScreen> {
  int _tab = 0;
  static const _labels = ['Requests', 'Jobs', 'Earnings', 'Chat', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProfileProvider).valueOrNull;
    if (user != null && !user.isArtisan) {
      return Scaffold(
        appBar: AppBar(title: const Text('Artisan Dashboard')),
        body: const Center(
          child: Text(
            'Your artisan application must be verified before you can use artisan mode.',
          ),
        ),
      );
    }
    final name = user?.name.isNotEmpty == true ? user!.name : 'Artisan';
    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? 'Artisan Dashboard' : _labels[_tab]),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(appModeProvider.notifier).state = AppMode.customer;
              context.go(AppRoutes.home);
            },
            icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
            label: const Text(
              'Customer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _tab == 0
            ? ListView(
                children: [
                  Text(name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Manage your service work in one place.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 22),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.45,
                    children: const [
                      _Metric(
                        label: 'New requests',
                        value: '—',
                        icon: Icons.notifications_none,
                      ),
                      _Metric(
                        label: 'Active jobs',
                        value: '—',
                        icon: Icons.work_outline,
                      ),
                      _Metric(
                        label: 'This week',
                        value: '—',
                        icon: Icons.payments_outlined,
                      ),
                      _Metric(
                        label: 'Rating',
                        value: '—',
                        icon: Icons.star_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _UnavailableWork(
                    message:
                        'Requests, jobs, and earnings will appear here when the booking provider is connected.',
                  ),
                ],
              )
            : _UnavailableWork(
                message:
                    '${_labels[_tab]} will appear here when the booking and chat providers are connected.',
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          if (index == 4) {
            context.push(AppRoutes.profile);
          } else {
            setState(() => _tab = index);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
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
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}

class _UnavailableWork extends StatelessWidget {
  const _UnavailableWork({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.work_outline,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}
