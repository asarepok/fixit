import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import '../services/notification_service.dart';

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

// A push that arrived while the app was open, live. Both platforms
// suppress the system tray for a foreground push, so app.dart listens to
// this to show something (a snackbar) itself.
final foregroundMessageProvider =
    StreamProvider.autoDispose<RemoteMessage>((ref) {
  return ref.watch(notificationServiceProvider).onForegroundMessage;
});

// Fires whenever FCM reissues this device a new token. app.dart listens
// to this alongside the initial registration on login, both save through
// AuthRepository.updateFcmToken.
final tokenRefreshProvider = StreamProvider.autoDispose<String>((ref) {
  return ref.watch(notificationServiceProvider).onTokenRefresh;
});

// The Settings screen's push-notifications switch. Turning it on asks
// for permission and saves a fresh token, same as a first login would,
// turning it off just records the preference, AuthRepository takes care
// of clearing the token that goes with it.
class NotificationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> setEnabled(bool enabled) async {
    state = const AsyncLoading();
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final uid = authRepository.currentUserId!;
      if (enabled) {
        final granted =
            await ref.read(notificationServiceProvider).requestPermission();
        if (granted) {
          final token = await ref.read(notificationServiceProvider).getToken();
          if (token != null) await authRepository.updateFcmToken(uid, token);
        }
      }
      await authRepository.setNotificationsEnabled(uid, enabled);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, void>(NotificationController.new);
