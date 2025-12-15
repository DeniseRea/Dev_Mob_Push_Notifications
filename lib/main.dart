import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_notifications/firebase_options.dart';
import 'package:push_notifications/layouts/notification_page.dart';

// Función para manejar mensajes en segundo plano
Future<void> _backgroundMessaging(RemoteMessage message) async {
  // Manejar la notificación en segundo plano
  print('Handling a background message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}

void main() async {
  //0. Inicializamos firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Registrar el manejador de mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(_backgroundMessaging);

  runApp(const MainApp());
}


class  MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notifications Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: NotificationPage(),
        ),
      );
  }
}

