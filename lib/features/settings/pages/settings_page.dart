import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final mode = ref.watch(themeProvider);

    return Scaffold(

      appBar: AppBar(
        title: const Text("Settings"),
      ),

      body: SwitchListTile(

        title: const Text("Dark Mode"),

        value: mode == ThemeMode.dark,

        onChanged: (value) {

          ref.read(themeProvider.notifier).state =
              value
                  ? ThemeMode.dark
                  : ThemeMode.light;

        },

      ),

    );

  }

}