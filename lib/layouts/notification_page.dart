import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'notification_detail_page.dart';

/// Página para gestionar notificaciones push de Firebase
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String? _fcmToken;
  bool _permissionsGranted = false;
  final List<Map<String, String>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;

    // Solicitar permisos
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    setState(() {
      _permissionsGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized;
    });

    if (!_permissionsGranted) {
      debugPrint('Permisos de notificaciones denegados');
      return;
    }

    // Obtener token FCM
    final token = await messaging.getToken();
    setState(() => _fcmToken = token);
    debugPrint('FCM Token: $token');

    // Escuchar mensajes en primer plano
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Manejar apertura desde notificación (app en segundo plano)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Verificar si la app se abrió desde una notificación (app cerrada)
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleInitialMessage(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'Sin título';
    final body = message.notification?.body ?? 'Sin contenido';

    setState(() {
      _notifications.add({'title': title, 'body': body});
    });

    if (mounted) {
      _showNotificationDialog(title, body);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final title = message.notification?.title ?? 'Sin título';
    final body = message.notification?.body ?? 'Sin contenido';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _navigateToDetail(title, body);
      }
    });
  }

  void _handleInitialMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'Sin título';
    final body = message.notification?.body ?? 'Sin contenido';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _navigateToDetail(title, body);
      }
    });
  }

  void _showNotificationDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(
          body,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToDetail(title, body);
            },
            child: const Text('Ver detalles'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(String title, String body) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailPage(title: title, body: body),
      ),
    );
  }

  Future<void> _copyTokenToClipboard() async {
    if (_fcmToken != null) {
      await Clipboard.setData(ClipboardData(text: _fcmToken!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token copiado al portapapeles')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Push'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPermissionsCard(),
            const SizedBox(height: 16),
            _buildTokenCard(),
            const SizedBox(height: 16),
            _buildNotificationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsCard() {
    return Card(
      child: ListTile(
        leading: Icon(
          _permissionsGranted ? Icons.check_circle : Icons.warning,
          color: _permissionsGranted ? Colors.green : Colors.orange,
        ),
        title: Text(
          _permissionsGranted ? 'Permisos otorgados' : 'Permisos denegados',
        ),
        subtitle: Text(
          _permissionsGranted
              ? 'La app puede recibir notificaciones'
              : 'Habilita los permisos en configuración',
        ),
      ),
    );
  }

  Widget _buildTokenCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FCM Token:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SelectableText(
              _fcmToken ?? 'Obteniendo token...',
              style: TextStyle(
                fontSize: 12,
                color: _fcmToken != null ? Colors.black87 : Colors.grey,
              ),
            ),
            if (_fcmToken != null) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _copyTokenToClipboard,
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copiar token'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notificaciones recibidas:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _notifications.isEmpty
                ? const Center(
                    child: Text(
                      'No hay notificaciones aún.\nEnvía una notificación de prueba desde Firebase Console.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.notifications),
                          title: Text(notification['title'] ?? ''),
                          subtitle: Text(
                            notification['body'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _navigateToDetail(
                            notification['title'] ?? '',
                            notification['body'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
