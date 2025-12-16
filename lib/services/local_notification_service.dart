import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio para manejar notificaciones locales
/// 
/// Proporciona métodos para:
/// - Mostrar notificaciones simples
/// - Mostrar notificaciones con botones de acción
/// - Programar notificaciones con temporizador
/// - Gestionar historial de notificaciones
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Claves para SharedPreferences
  static const String _historyKey = 'notification_history';
  static const String _scheduledKey = 'scheduled_notifications';
  static const int _maxHistoryItems = 50;

  /// Inicializa el servicio de notificaciones locales
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    // Inicializar zonas horarias para notificaciones programadas
    tz.initializeTimeZones();
    
    // Configurar zona horaria local usando offset del dispositivo
    _configureLocalTimeZone();

    // Solicitar permisos de notificación en Android 13+
    await _requestPermissions();
  }

  /// Configura la zona horaria local basada en el offset del dispositivo
  static void _configureLocalTimeZone() {
    final now = DateTime.now();
    final offsetInHours = now.timeZoneOffset.inHours;
    
    // Buscar una zona horaria que coincida con el offset actual
    String timeZoneName = 'America/Bogota'; // Default para Colombia (UTC-5)
    
    // Mapeo simple de offsets comunes
    final offsetToTimezone = {
      -5: 'America/Bogota',
      -4: 'America/Caracas',
      -3: 'America/Sao_Paulo',
      -6: 'America/Mexico_City',
      -7: 'America/Denver',
      -8: 'America/Los_Angeles',
      0: 'Europe/London',
      1: 'Europe/Paris',
      2: 'Europe/Kiev',
    };
    
    if (offsetToTimezone.containsKey(offsetInHours)) {
      timeZoneName = offsetToTimezone[offsetInHours]!;
    }
    
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Zona horaria configurada: $timeZoneName (offset: $offsetInHours)');
    } catch (e) {
      debugPrint('Error configurando zona horaria, usando UTC: $e');
    }
  }

  /// Solicita permisos de notificación
  static Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  /// Maneja el tap en una notificación (foreground)
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notificación presionada: ${response.payload}');
  }

  /// Maneja el tap en una notificación (background)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    debugPrint('Notificación background presionada: ${response.payload}');
  }

  /// Muestra una notificación simple
  static Future<void> showSimpleNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'simple_channel',
      'Notificaciones Simples',
      channelDescription: 'Notificaciones básicas sin botones',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      _generateNotificationId(),
      title,
      body,
      details,
    );

    await _saveToHistory(title, body, 'simple');
  }

  /// Muestra notificación con botones de acción
  static Future<void> showNotificationWithButtons({
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'actions_channel',
      'Notificaciones con Acciones',
      channelDescription: 'Notificaciones con botones',
      importance: Importance.high,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'action_accept',
          'Aceptar',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'action_reject',
          'Rechazar',
          cancelNotification: true,
        ),
      ],
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      _generateNotificationId(),
      title,
      body,
      details,
      payload: 'with_buttons',
    );

    await _saveToHistory(title, body, 'with_buttons');
  }

  /// Programa una notificación con temporizador
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required int secondsDelay,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(Duration(seconds: secondsDelay));

    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Notificaciones Programadas',
      channelDescription: 'Notificaciones con temporizador',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    final notificationId = _generateNotificationId();

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'scheduled_$notificationId',
    );

    await _saveScheduledNotification(notificationId, title, body, scheduledDate);
    
    // También guardar en historial como programada
    await _saveToHistory(title, body, 'scheduled');
    
    debugPrint('Notificación programada para: $scheduledDate (ahora: $now)');
  }

  /// Obtiene todas las notificaciones pendientes
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _notifications.pendingNotificationRequests();
  }

  /// Cancela una notificación programada
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    await _removeScheduledNotification(id);
  }

  /// Cancela todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scheduledKey);
  }

  /// Obtiene historial de notificaciones
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    return history.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList();
  }

  /// Obtiene notificaciones programadas guardadas
  static Future<List<Map<String, dynamic>>> getScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final scheduled = prefs.getStringList(_scheduledKey) ?? [];

    return scheduled.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList();
  }

  // --- MÉTODOS PRIVADOS ---

  /// Genera un ID único para notificaciones
  static int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  /// Guarda notificación en historial
  static Future<void> _saveToHistory(
    String title,
    String body,
    String type,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    final notification = jsonEncode({
      'title': title,
      'body': body,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
    });

    history.insert(0, notification);

    // Mantener solo las últimas N notificaciones
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    await prefs.setStringList(_historyKey, history);
  }

  /// Guarda notificación programada
  static Future<void> _saveScheduledNotification(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledDate,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final scheduled = prefs.getStringList(_scheduledKey) ?? [];

    final notification = jsonEncode({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toIso8601String(),
    });

    scheduled.add(notification);
    await prefs.setStringList(_scheduledKey, scheduled);
  }

  /// Elimina notificación programada del almacenamiento
  static Future<void> _removeScheduledNotification(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final scheduled = prefs.getStringList(_scheduledKey) ?? [];

    final updated = scheduled.where((item) {
      final data = jsonDecode(item) as Map<String, dynamic>;
      return data['id'] != id;
    }).toList();

    await prefs.setStringList(_scheduledKey, updated);
  }
}
