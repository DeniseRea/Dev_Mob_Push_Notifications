import 'package:flutter/material.dart';

/// Pantalla principal con menú de opciones de notificaciones
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuCard(
            icon: Icons.notifications,
            title: 'Notificación Simple',
            subtitle: 'Muestra una notificación básica',
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, '/simple'),
          ),
          _MenuCard(
            icon: Icons.notifications_active,
            title: 'Con Botones',
            subtitle: 'Notificación con acciones',
            color: Colors.green,
            onTap: () => Navigator.pushNamed(context, '/buttons'),
          ),
          _MenuCard(
            icon: Icons.schedule,
            title: 'Programadas',
            subtitle: 'Notificaciones con temporizador',
            color: Colors.orange,
            onTap: () => Navigator.pushNamed(context, '/scheduled'),
          ),
          _MenuCard(
            icon: Icons.history,
            title: 'Historial',
            subtitle: 'Ver notificaciones enviadas',
            color: Colors.purple,
            onTap: () => Navigator.pushNamed(context, '/history'),
          ),
          _MenuCard(
            icon: Icons.cloud,
            title: 'Firebase Push',
            subtitle: 'Notificaciones remotas',
            color: Colors.red,
            onTap: () => Navigator.pushNamed(context, '/firebase'),
          ),
        ],
      ),
    );
  }
}

/// Widget reutilizable para las tarjetas del menú
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
