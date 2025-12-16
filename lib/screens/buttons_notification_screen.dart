import 'package:flutter/material.dart';

import '../services/local_notification_service.dart';

/// Pantalla para enviar notificaciones con botones de acción
class ButtonsNotificationScreen extends StatefulWidget {
  const ButtonsNotificationScreen({super.key});

  @override
  State<ButtonsNotificationScreen> createState() => _ButtonsNotificationScreenState();
}

class _ButtonsNotificationScreenState extends State<ButtonsNotificationScreen> {
  final _titleController = TextEditingController(text: 'Confirmar acción');
  final _bodyController = TextEditingController(text: '¿Deseas continuar?');

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    await LocalNotificationService.showNotificationWithButtons(
      title: _titleController.text,
      body: _bodyController.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notificación con botones enviada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Con Botones'),
        backgroundColor: Colors.green,
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
              icon: const Icon(Icons.touch_app),
              label: const Text('Enviar con Botones'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
