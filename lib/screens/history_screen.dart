import 'package:flutter/material.dart';

import '../services/local_notification_service.dart';

/// Pantalla que muestra el historial de notificaciones enviadas
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await LocalNotificationService.getHistory();
    setState(() => _history = history);
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'simple':
        return Icons.notifications;
      case 'with_buttons':
        return Icons.notifications_active;
      case 'scheduled':
        return Icons.schedule;
      default:
        return Icons.notification_important;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Refrescar historial',
          ),
        ],
      ),
      body: _history.isEmpty
          ? const Center(
              child: Text(
                'No hay notificaciones en el historial',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                final timestamp = DateTime.parse(item['timestamp'] as String);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.withOpacity(0.2),
                      child: Icon(
                        _getIconForType(item['type'] as String?),
                        color: Colors.purple,
                      ),
                    ),
                    title: Text(item['title'] as String? ?? 'Sin título'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['body'] as String? ?? 'Sin contenido'),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
