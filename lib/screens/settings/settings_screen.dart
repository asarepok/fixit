import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            title: const Text('Dark Mode'),
            subtitle: const Text('Use the dark FixIt GH colour scheme'),
            value: mode == ThemeMode.dark,
            onChanged: (enabled) => ref.read(themeProvider.notifier).state =
                enabled ? ThemeMode.dark : ThemeMode.light,
          ),
        ),
      ),
    );
  }
}
