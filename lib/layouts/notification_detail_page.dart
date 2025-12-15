import 'package:flutter/material.dart';

class NotificationDetailPage extends StatelessWidget {
  final String title;
  final String body;

   const NotificationDetailPage({
    super.key,
    required this.title,
    required this.body
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Detail'),
      ),
      body:  Column(
        children: [
          Text('Title: $title', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          const SizedBox(height: 20,),
          Text('Body: $body', style: const TextStyle(fontSize: 16),),
        ],
      ),
    );
  }
}
