import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final List<String> notifications;

  const NotificationPage({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () {
            Navigator.pop(context);  // Handle back button press
          },
        ),
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              notifications[index],
              style: const TextStyle(fontSize: 18),  // Set text size to 18
            ),
          );
        },
      ),
    );
  }
}
