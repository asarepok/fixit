import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
