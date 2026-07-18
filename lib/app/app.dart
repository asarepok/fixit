import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/theme_provider.dart';
import 'router.dart';
import 'theme.dart';

// The root widget of the app. main.dart wraps this in a ProviderScope and
// passes it to runApp. It wires up the app's theme, dark/light mode, the
// go_router setup from router.dart, and push notifications: registering
// this device's token on sign-in/token refresh, and surfacing a push that
// arrives while the app is open (both platforms hide the system tray for
// a foreground push, so nothing shows without this).
class FixItGHApp extends ConsumerWidget {
  const FixItGHApp({super.key});

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> _registerPushToken(WidgetRef ref, String uid) async {
    final authRepository = ref.read(authRepositoryProvider);
    // Respect a user who's already turned notifications off in Settings,
    // otherwise this would silently re-enable them on every app launch.
    final profile = await authRepository.getCurrentUserProfile();
    if (profile != null && !profile.notificationsEnabled) return;

    final notificationService = ref.read(notificationServiceProvider);
    final granted = await notificationService.requestPermission();
    if (!granted) return;
    final token = await notificationService.getToken();
    if (token != null) {
      await authRepository.updateFcmToken(uid, token);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<String?>>(authStateProvider, (previous, next) {
      final uid = next.valueOrNull;
      if (uid != null) _registerPushToken(ref, uid);
    });

    ref.listen<AsyncValue<String>>(tokenRefreshProvider, (previous, next) {
      final token = next.valueOrNull;
      final uid = ref.read(authStateProvider).valueOrNull;
      if (token != null && uid != null) {
        final authRepository = ref.read(authRepositoryProvider);
        authRepository.getCurrentUserProfile().then((profile) {
          if (profile == null || profile.notificationsEnabled) {
            authRepository.updateFcmToken(uid, token);
          }
        });
      }
    });

    ref.listen(foregroundMessageProvider, (previous, next) {
      final message = next.valueOrNull;
      final notification = message?.notification;
      if (notification == null) return;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            [
              notification.title,
              notification.body,
            ].whereType<String>().join(': '),
          ),
        ),
      );
    });

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: "FixIt GH",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeProvider),
      routerConfig: appRouter,
    );
  }
}
