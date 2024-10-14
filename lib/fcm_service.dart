import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_notification/local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:push_notification/main.dart';

class FCMService {
  static Future<void> backgroundHandler(RemoteMessage message) async {
    // Handle background notifications
    log('Handling a background message: ${message.messageId}');

    // Show local notification for background FCM
    LocalNotifications.showSimpleNotification(
      title: message.notification?.title ?? 'Background Notification',
      body: message.notification?.body ?? 'No body',
      payload: message.data['your_key'] ?? 'No payload',
    );
  }

  static Future<void> initializeFCM(BuildContext context) async {
    // Request permission for notifications
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
      String? token = await messaging.getToken();
      log("FCM Token: $token");
    } else {
      log('User declined or has not accepted permission');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Received a message while in the foreground!');
      if (message.notification != null) {
        // Show a local notification
        LocalNotifications.showSimpleNotification(
          title: message.notification?.title ?? 'Foreground Notification',
          body: message.notification?.body ?? 'No body',
          payload: message.data['your_key'] ?? 'No payload',
        );
      }
    });

    // Handle when the notification is clicked and app is in background but still open
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('A notification was clicked and the app was opened from background!');
      if (message.data != null) {
        String payload = message.data.toString() ?? 'No payload';
        _handleNotificationTap(context, payload);
      }
    });

    // Handle background messages (when the app is terminated)
    FirebaseMessaging.onBackgroundMessage(FCMService.backgroundHandler);
  }

  // Handle notification tap action (pass payload to some page or functionality)
  static void _handleNotificationTap(BuildContext context, String payload) {
    log('Handling notification tap with payload: $payload');

    // Navigate to a specific screen or perform any action based on the payload
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnotherPage(payload: payload)),
    );
  }
}
