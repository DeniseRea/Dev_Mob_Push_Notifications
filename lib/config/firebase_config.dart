/// Configuración centralizada para Firebase y notificaciones push
class FirebaseConfig {
  // Configuración de canales de notificación
  static const String defaultChannelId = 'high_importance_channel';
  static const String defaultChannelName = 'High Importance Notifications';
  static const String defaultChannelDescription = 'This channel is used for important notifications.';
  
  // Configuración de Firestore (cuando lo necesites)
  static const String usersCollection = 'users';
  static const String notificationsCollection = 'notifications';
  static const String tokensCollection = 'fcm_tokens';
  
  // Timeouts
  static const Duration notificationTimeout = Duration(seconds: 30);
  static const Duration firestoreTimeout = Duration(seconds: 10);
}
