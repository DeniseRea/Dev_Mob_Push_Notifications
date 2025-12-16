import 'package:flutter/material.dart';

import '../services/local_notification_service.dart';

/// Pantalla para enviar notificaciones simples
class SimpleNotificationScreen extends StatefulWidget {
  const SimpleNotificationScreen({super.key});

  @override
  State<SimpleNotificationScreen> createState() => _SimpleNotificationScreenState();
}

class _SimpleNotificationScreenState extends State<SimpleNotificationScreen> {
  final _titleController = TextEditingController(text: 'Hola');
  final _bodyController = TextEditingController(text: 'Esta es una notificación simple');

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    await LocalNotificationService.showSimpleNotification(
      title: _titleController.text,
      body: _bodyController.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notificación enviada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificación Simple'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _sendNotification,
              icon: const Icon(Icons.send),
              label: const Text('Enviar Notificación'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
