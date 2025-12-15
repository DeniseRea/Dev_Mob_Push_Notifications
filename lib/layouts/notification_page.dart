import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'notification_detail_page.dart';

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
    // 1. Solicitar permisos
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    setState(() {
      _permissionsGranted = settings.authorizationStatus == AuthorizationStatus.authorized;
    });

    if (!_permissionsGranted) {
      print('Permisos de notificaciones denegados');
      return;
    }

    // 2. Obtener token FCM
    final token = await messaging.getToken();
    setState(() {
      _fcmToken = token;
    });
    print('FCM Token: $token');

    // 3. Escuchar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? "Sin título";
      final body = message.notification?.body ?? "Sin contenido";

      // Agregar a la lista
      setState(() {
        _notifications.add({'title': title, 'body': body});
      });

      // Mostrar diálogo solo si el widget está montado
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(
              body,
              maxLines: 3,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationDetailPage(
                        title: title,
                        body: body,
                      ),
                    ),
                  );
                },
                child: const Text("Ver detalles"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cerrar"),
              ),
            ],
          ),
        );
      }
    });

    // 4. Manejar cuando se abre la app desde una notificación (app en segundo plano)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final title = message.notification?.title ?? "Sin título";
      final body = message.notification?.body ?? "Sin contenido";

      // Navegar de forma segura
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDetailPage(
                title: title,
                body: body,
              ),
            ),
          );
        }
      });
    });

    // 5. Verificar si la app se abrió desde una notificación (app cerrada)
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      final title = initialMessage.notification?.title ?? "Sin título";
      final body = initialMessage.notification?.body ?? "Sin contenido";

      // Navegar de forma segura después de que el widget esté completamente construido
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDetailPage(
                title: title,
                body: body,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado de permisos
            Card(
              child: ListTile(
                leading: Icon(
                  _permissionsGranted ? Icons.check_circle : Icons.warning,
                  color: _permissionsGranted ? Colors.green : Colors.orange,
                ),
                title: Text(_permissionsGranted
                    ? 'Permisos otorgados'
                    : 'Permisos denegados'),
                subtitle: Text(_permissionsGranted
                    ? 'La app puede recibir notificaciones'
                    : 'Habilita los permisos en configuración'),
              ),
            ),
            const SizedBox(height: 16),

            // Token FCM
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FCM Token:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _fcmToken ?? 'Obteniendo token...',
                      style: TextStyle(
                        fontSize: 12,
                        color: _fcmToken != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_fcmToken != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          // Copiar al portapapeles
                          print('Token copiado: $_fcmToken');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Token copiado al log'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Ver en consola'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de notificaciones
            const Text(
              'Notificaciones recibidas:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationDetailPage(
                                    title: notification['title'] ?? '',
                                    body: notification['body'] ?? '',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
