import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification/local_notifications.dart';
import 'package:push_notification/notidetail.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz; // Keep this for timezone data
import 'package:timezone/timezone.dart' as tz; // Correct import for TZDateTime

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await LocalNotifications.init();

  // Listen for notification taps
  LocalNotifications.onClickNotification.listen((payload) {
    MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => NotificationDetailPage(payload: payload),
      ),
    );
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Notification Demo',
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
        title: const Text('Notification Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                LocalNotifications.showSimpleNotification(
                  title: 'Hello',
                  body: 'This is a simple notification',
                  payload: 'simple_payload',
                );
              },
              child: const Text('Show Simple Notification'),
            ),
            ElevatedButton(
              onPressed: () {
                LocalNotifications.showPeriodicNotifications(
                  title: 'Periodic Notification',
                  body: 'This notification shows periodically every minute.',
                  payload: 'periodic_payload',
                );
              },
              child: const Text('Show Periodic Notification'),
            ),
            ElevatedButton(
              onPressed: () {
                // Schedule notification for 5 seconds from now
                DateTime scheduledDate =
                    DateTime.now().add(Duration(seconds: 5));
                LocalNotifications.showScheduleNotification(
                  title: "Scheduled Notification",
                  body: "This is a scheduled notification.",
                  payload: "scheduled_payload",
                  scheduledDate: tz.TZDateTime.from(scheduledDate,
                      tz.local), // Convert DateTime to TZDateTime
                );
              },
              child: const Text('Show Scheduled Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
