# push_notifications

Proyecto Flutter para recibir notificaciones push usando Firebase Messaging.

## Requisitos
- Flutter (estable) y `flutter` en PATH
- Android SDK / Android Studio
- Java (JDK) compatible con Gradle
- Firebase CLI (`firebase`) y FlutterFire CLI (`flutterfire`)
- Cuenta de Firebase y proyecto configurado

## Instalación rápida
1. Abrir terminal en la raíz del proyecto:
    - `cd D:\Dev_Mob_Push_Notifications`
2. Instalar dependencias:
    - `flutter pub add firebase_core`
    - `flutter pub add firebase_messaging`
    - `flutter pub get`
3. Iniciar sesión en Firebase:
    - `firebase login`
4. Configurar Firebase para Flutter:
    - `flutterfire configure`
5. Colocar `google-services.json` en `android/app/`

## Cambios Android (resumen)
- En `android/build.gradle` añadir en `dependencies`:
    - `classpath 'com.google.gms:google-services:4.3.15'` (o versión recomendada)
- En `android/app/build.gradle` al final:
    - `apply plugin: 'com.google.gms.google-services'`
- En `android/app/src/main/AndroidManifest.xml` asegurar permisos:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
