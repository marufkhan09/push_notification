import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize time zones for notifications
  tz.initializeTimeZones();

  // Initialize local notifications
  await LocalNotifications.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Notification Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Static Notification for iOS'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            LocalNotifications.showSimpleNotification(
              title: 'Hello',
              body: 'This is a static notification',
              payload: 'notification_payload',
            );
          },
          child: const Text('Show Notification'),
        ),
      ),
    );
  }
}

// Notification service class
class LocalNotifications {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle notification received in foreground
      },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsDarwin,
    );

    // Initialize notifications
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
      },
    );

    // Request permissions for iOS
    final bool? granted = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    log("Notification permission granted: $granted");
  }

  // Show a simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    log('Notification triggered');
  }
}
