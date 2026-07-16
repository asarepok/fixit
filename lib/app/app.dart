import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import 'router.dart';
import 'theme.dart';

// The root widget of the app. main.dart wraps this in a ProviderScope and
// passes it to runApp. It wires up the app's theme, dark/light mode, and
// the go_router setup from router.dart.
class FixItGHApp extends ConsumerWidget {
  const FixItGHApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "FixIt GH",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeProvider),
      routerConfig: appRouter,
    );
  }
}
