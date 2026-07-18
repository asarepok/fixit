import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/grouped_card.dart';
import '../../widgets/section_heading.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final user = ref.watch(currentUserProfileProvider).valueOrNull;
    final notificationsLoading = ref.watch(notificationControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionHeading(eyebrow: 'Look and feel', title: 'Appearance'),
          const SizedBox(height: 12),
          GroupedCard(
            children: [
              _SwitchRow(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Use a dark colour scheme throughout the app',
                value: themeMode == ThemeMode.dark,
                onChanged: (enabled) => ref.read(themeProvider.notifier).state =
                    enabled ? ThemeMode.dark : ThemeMode.light,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SectionHeading(eyebrow: 'Stay in the loop', title: 'Notifications'),
          const SizedBox(height: 12),
          GroupedCard(
            children: [
              _SwitchRow(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Booking updates, payments, and new messages',
                value: user?.notificationsEnabled ?? true,
                loading: notificationsLoading,
                onChanged: (enabled) => ref
                    .read(notificationControllerProvider.notifier)
                    .setEnabled(enabled),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool loading;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: loading ? null : onChanged,
    );
  }
}
