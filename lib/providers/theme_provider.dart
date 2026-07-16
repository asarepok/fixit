import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Holds the app's current light/dark mode. Read by app/app.dart to set
// MaterialApp's themeMode, and changed by the settings screen's dark mode
// switch.
final themeProvider =
    StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});