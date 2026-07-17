import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_mode_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/extensions.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _updateMyLocation(BuildContext context, WidgetRef ref) async {
    try {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentLocation();
      await ref
          .read(authControllerProvider.notifier)
          .updateMyLocation(position.latitude, position.longitude);
      if (context.mounted) context.showSnack('Location updated successfully');
    } catch (error) {
      if (context.mounted) context.showSnack(error.toString());
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();
    ref.read(appModeProvider.notifier).state = AppMode.customer;
    if (context.mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final mode = ref.watch(appModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No profile found'));
          }
          final initials = user.name.trim().isEmpty
              ? 'U'
              : user.name
                    .trim()
                    .split(RegExp(r'\s+'))
                    .take(2)
                    .map((word) => word[0])
                    .join()
                    .toUpperCase();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name.isEmpty ? 'Your account' : user.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user.email,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ProfileOption(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => context.push(AppRoutes.editProfile),
              ),
              _ProfileOption(
                icon: Icons.location_on_outlined,
                title: 'Update My Location',
                onTap: () => _updateMyLocation(context, ref),
              ),
              _ProfileOption(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => context.push(AppRoutes.settings),
              ),
              const SizedBox(height: 8),
              if (user.isArtisan)
                _ProfileOption(
                  icon: Icons.swap_horiz_rounded,
                  title: mode == AppMode.artisan
                      ? 'Switch to Customer Mode'
                      : 'Switch to Artisan Mode',
                  highlighted: true,
                  onTap: () {
                    final artisanMode = mode != AppMode.artisan;
                    ref.read(appModeProvider.notifier).state = artisanMode
                        ? AppMode.artisan
                        : AppMode.customer;
                    context.go(
                      artisanMode ? AppRoutes.artisanDashboard : AppRoutes.home,
                    );
                  },
                )
              else
                _ProfileOption(
                  icon: Icons.handyman_outlined,
                  title: user.hasPendingArtisanApplication
                      ? 'View Artisan Application'
                      : 'Become an Artisan',
                  highlighted: true,
                  onTap: () => context.push(
                    user.hasPendingArtisanApplication
                        ? AppRoutes.artisanApplicationStatus
                        : AppRoutes.becomeArtisan,
                  ),
                ),
              const SizedBox(height: 8),
              _ProfileOption(
                icon: Icons.logout_rounded,
                title: 'Log Out',
                onTap: () => _logout(context, ref),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.highlighted = false,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, color: highlighted ? const Color(0xFFFFA62B) : null),
      title: Text(
        title,
        style: highlighted
            ? const TextStyle(
                color: Color(0xFFFFA62B),
                fontWeight: FontWeight.w700,
              )
            : null,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    ),
  );
}
