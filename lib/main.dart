import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_notification/local_notifications.dart';
import 'fcm_service.dart'; // Import your FCM service file

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await LocalNotifications.init(); // Initialize Local Notifications

  // Handle notifications when the app is in a terminated state
  FirebaseMessaging.onBackgroundMessage(FCMService.backgroundHandler);

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Notification Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const Homepage(),
        '/another': (context) => const AnotherPage(),
      },
    );
  }
}

// In your existing Homepage, add the FCM initialization
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    listenToNotifications();
    FCMService.initializeFCM(); // Initialize FCM
    super.initState();
  }

  listenToNotifications() {
    log("Listening to notification");

    // Listen for local notifications
    LocalNotifications.onClickNotification.stream.listen((event) {
      log(event);
      Navigator.pushNamed(context, '/another', arguments: event);
    });

    // Listen for FCM messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(context, '/another',
          arguments: message.data.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter Local Notifications")),
      body: Container(
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.notifications_outlined),
                onPressed: () {
                  LocalNotifications.showSimpleNotification(
                    title: "Simple Notification",
                    body: "This is a simple notification",
                    payload: "This is simple data",
                  );
                },
                label: Text("Simple Notification"),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.timer_outlined),
                onPressed: () {
                  LocalNotifications.showPeriodicNotifications(
                    title: "Periodic Notification",
                    body: "This is a Periodic Notification",
                    payload: "This is periodic data",
                  );
                },
                label: Text("Periodic Notifications"),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.timer_outlined),
                onPressed: () {
                  LocalNotifications.showScheduleNotification(
                    title: "Schedule Notification",
                    body: "This is a Schedule Notification",
                    payload: "This is schedule data",
                  );
                },
                label: Text("Schedule Notifications"),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.delete_outline),
                onPressed: () {
                  LocalNotifications.cancel(1);
                },
                label: Text("Close Periodic Notifications"),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.delete_forever_outlined),
                onPressed: () {
                  LocalNotifications.cancelAll();
                },
                label: Text("Cancel All Notifications"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Your AnotherPage class remains unchanged
class AnotherPage extends StatelessWidget {
  const AnotherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: Text("Another Page")),
      body: Center(child: Text(data.toString())),
    );
  }
}
