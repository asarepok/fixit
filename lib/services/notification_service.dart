import 'package:firebase_messaging/firebase_messaging.dart';

// Thin wrapper around FirebaseMessaging: permission, this device's push
// token, and the streams a provider needs to react to a push. Screens
// and providers should read this through
// lib/providers/notification_provider.dart, not create it directly.
class NotificationService {
  final _messaging = FirebaseMessaging.instance;

  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> getToken() => _messaging.getToken();

  // Fires when FCM reissues this device a new token, rare, but when it
  // happens the old one stops working, so the new one needs saving too.
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  // Fires when a push arrives while the app is in the foreground. Both
  // Android and iOS suppress the system notification tray in that case,
  // so this is the only way the app finds out a message arrived at all
  // while it's open.
  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;
}
