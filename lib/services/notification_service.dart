import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    try {
      await Firebase.initializeApp();

      // Request permission
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      // Get token
      final token = await messaging.getToken();
      print('FCM Token: $token');

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        if (message.notification != null) {
          _showLocalNotification(
            message.notification!.title ?? '',
            message.notification!.body ?? '',
          );
        }
      });

      // Background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      // Firebase isn't configured natively yet (no google-services.json).
      // Don't block app startup on push notifications being unavailable.
      print('NotificationService init skipped: $e');
    }
  }

  void _showLocalNotification(String title, String body) {
    // Show local notification when message received in foreground
    print('Notification: $title - $body');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}