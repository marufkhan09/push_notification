import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_notification/local_notifications.dart';

class FCMService {
  static Future<void> backgroundHandler(RemoteMessage message) async {
    // Handle background notifications
    log('Handling a background message: ${message.messageId}');
    LocalNotifications.showSimpleNotification(
      title: message.notification!.title!,
      body: message.notification!.body!,
      payload: message.data.toString(),
    );
  }

  static Future<void> initializeFCM() async {
    // Request permission for notifications
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');

      // Get the token for this device
      String? token = await messaging.getToken();
      log("FCM Token: $token");
    } else {
      log('User declined or has not accepted permission');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Received a message while in the foreground!');
      if (message.notification != null) {
        // Show a local notification here if you want
        LocalNotifications.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: message.data.toString(),
        );
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(FCMService.backgroundHandler);
  }
}
