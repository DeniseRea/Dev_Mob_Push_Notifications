import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../services/local_notification_service.dart';

/// Pantalla para programar notificaciones con temporizador
class ScheduledNotificationScreen extends StatefulWidget {
  const ScheduledNotificationScreen({super.key});

  @override
  State<ScheduledNotificationScreen> createState() =>
      _ScheduledNotificationScreenState();
}

class _ScheduledNotificationScreenState
    extends State<ScheduledNotificationScreen> {
  final _titleController = TextEditingController(text: 'Recordatorio');
  final _bodyController =
      TextEditingController(text: 'No olvides revisar la app');
  int _selectedSeconds = 10;
  List<PendingNotificationRequest> _pendingNotifications = [];

  static const List<_TimeOption> _timeOptions = [
    _TimeOption(10, '10 segundos'),
    _TimeOption(30, '30 segundos'),
    _TimeOption(60, '1 minuto'),
    _TimeOption(300, '5 minutos'),
  ];

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingNotifications() async {
    final pending = await LocalNotificationService.getPendingNotifications();
    setState(() => _pendingNotifications = pending);
  }

  Future<void> _scheduleNotification() async {
    await LocalNotificationService.scheduleNotification(
      title: _titleController.text,
      body: _bodyController.text,
      secondsDelay: _selectedSeconds,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Programada para $_selectedSeconds segundos')),
    );
    _loadPendingNotifications();
  }

  Future<void> _cancelNotification(int id) async {
    await LocalNotificationService.cancelNotification(id);
    _loadPendingNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programadas'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingNotifications,
            tooltip: 'Refrescar lista',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildForm(),
          const Divider(),
          _buildPendingList(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
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
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedSeconds,
            decoration: const InputDecoration(
              labelText: 'Programar en',
              border: OutlineInputBorder(),
            ),
            items: _timeOptions
                .map((option) => DropdownMenuItem(
                      value: option.seconds,
                      child: Text(option.label),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedSeconds = value);
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _scheduleNotification,
            icon: const Icon(Icons.schedule_send),
            label: const Text('Programar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingList() {
    return Expanded(
      child: _pendingNotifications.isEmpty
          ? const Center(
              child: Text(
                'No hay notificaciones programadas',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _pendingNotifications.length,
              itemBuilder: (context, index) {
                final notification = _pendingNotifications[index];
                return ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.orange),
                  title: Text(notification.title ?? 'Sin título'),
                  subtitle: Text(notification.body ?? 'Sin contenido'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _cancelNotification(notification.id),
                    tooltip: 'Cancelar notificación',
                  ),
                );
              },
            ),
    );
  }
}

/// Clase auxiliar para las opciones de tiempo
class _TimeOption {
  final int seconds;
  final String label;

  const _TimeOption(this.seconds, this.label);
}
