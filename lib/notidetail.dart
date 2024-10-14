import 'package:flutter/material.dart';

class NotificationDetailPage extends StatelessWidget {
  final String payload;

  const NotificationDetailPage({Key? key, required this.payload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification Details"),
      ),
      body: Center(
        child: Text("Payload: $payload"),
      ),
    );
  }
}
