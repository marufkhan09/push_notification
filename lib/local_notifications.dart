import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification/main.dart';
import 'package:push_notification/notidetail.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Top-level background handler function
Future<void> backgroundHandler(NotificationResponse response) async {
  LocalNotifications.onNotificationTap(response);
}

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();

  // on tap on any notification
  static void onNotificationTap(NotificationResponse notificationResponse) {
    onClickNotification.add(notificationResponse.payload!);
  }

  // Initialize the local notifications
  static Future<void> init() async {
    // Initialize Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize iOS settings
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );

    // Initialize Linux settings (if needed)
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    // Apply platform-specific initialization settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    // Request permissions for Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request permissions for iOS
    final bool? granted = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    log("Notification permission granted (iOS): $granted");

    // Initialize notifications
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap in the foreground
        onNotificationTap(response);
      },
      onDidReceiveBackgroundNotificationResponse: backgroundHandler,
    );

    // Listen for notification taps
    onClickNotification.listen((payload) {
      // Navigate to the desired screen based on the payload
      MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => NotificationDetailPage(payload: payload),
        ),
      );
    });
  }

  // Show a simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    // Android Notification Details
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    // iOS Notification Details
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      badgeNumber: 1,
    );

    // Combine notification details for both platforms
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
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

  // Show periodic notifications
  static Future showPeriodicNotifications({
    required String title,
    required String body,
    required String payload,
  }) async {
    // Android Notification Details
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_2',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    // iOS Notification Details
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      badgeNumber: 1,
    );

    // Combine notification details for both platforms
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      1,
      title,
      body,
      RepeatInterval.everyMinute,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Schedule a local notification
  static Future showScheduleNotification({
    required String title,
    required String body,
    required String payload,
    required tz.TZDateTime scheduledDate, // Ensure this is TZDateTime
  }) async {
    tz.initializeTimeZones();
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      title,
      body,
      scheduledDate, // Now this is already a TZDateTime
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_3',
          'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS: DarwinNotificationDetails(
          badgeNumber: 1,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Close a specific channel notification
  static Future cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Close all notifications
  static Future cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
