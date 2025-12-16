import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'layouts/notification_page.dart';
import 'screens/buttons_notification_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/scheduled_notification_screen.dart';
import 'screens/simple_notification_screen.dart';
import 'services/local_notification_service.dart';

/// Manejador de mensajes en segundo plano (Firebase)
@pragma('vm:entry-point')
Future<void> _backgroundMessaging(RemoteMessage message) async {
  debugPrint('Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Registrar manejador de mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(_backgroundMessaging);

  // Inicializar notificaciones locales
  await LocalNotificationService.initialize();

  runApp(const MainApp());
}

/// Aplicación principal de Push Notifications
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/simple': (context) => const SimpleNotificationScreen(),
        '/buttons': (context) => const ButtonsNotificationScreen(),
        '/scheduled': (context) => const ScheduledNotificationScreen(),
        '/history': (context) => const HistoryScreen(),
        '/firebase': (context) => const Scaffold(body: NotificationPage()),
      },
    );
  }
}
