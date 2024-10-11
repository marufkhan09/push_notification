import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This will be called when the app is in the background
  log("Handling a background message: ${message.messageId}");
  // You can also show notifications or perform other actions here
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Register the background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notification Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _message = '';

  @override
  void initState() {
    super.initState();
    // Request permission for iOS
    FirebaseMessaging.instance.requestPermission();

    // Get the FCM token
    FirebaseMessaging.instance.getToken().then((token) {
      log("FCM Token: $token"); // Use this token to send notifications
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("Received a foreground message: ${message.messageId}");
      setState(() {
        _message = message.notification?.body ?? "No message body";
      });

      // Show a notification or do something with the message here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Push Notification Example"),
      ),
      body: Center(
        child: Text(_message),
      ),
    );
  }
}
