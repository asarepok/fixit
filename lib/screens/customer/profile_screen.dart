import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_mode_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/grouped_card.dart';

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
              Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name.isEmpty ? 'Your account' : user.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 3),
                  Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user.isArtisan)
                          Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        if (user.isArtisan) const SizedBox(width: 4),
                        Text(
                          user.isArtisan ? 'Verified artisan' : 'Customer',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              GroupedCard(
                indent: 56,
                children: [
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
                ],
              ),
              const SizedBox(height: 14),
              GroupedCard(
                indent: 56,
                children: [
                  if (user.isArtisan)
                    _ProfileOption(
                      icon: Icons.swap_horiz_rounded,
                      title: mode == AppMode.artisan
                          ? 'Switch to Booking'
                          : 'Switch to Working',
                      highlighted: true,
                      onTap: () {
                        final artisanMode = mode != AppMode.artisan;
                        ref.read(appModeProvider.notifier).state = artisanMode
                            ? AppMode.artisan
                            : AppMode.customer;
                        context.go(
                          artisanMode
                              ? AppRoutes.artisanDashboard
                              : AppRoutes.home,
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
                ],
              ),
              const SizedBox(height: 14),
              GroupedCard(
                indent: 56,
                children: [
                  _ProfileOption(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    onTap: () => _logout(context, ref),
                  ),
                ],
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
  Widget build(BuildContext context) {
    final accent = AppColors.accentOf(context);
    return ListTile(
      leading: Icon(icon, color: highlighted ? accent : null),
      title: Text(
        title,
        style: highlighted
            ? TextStyle(color: accent, fontWeight: FontWeight.w700)
            : null,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
