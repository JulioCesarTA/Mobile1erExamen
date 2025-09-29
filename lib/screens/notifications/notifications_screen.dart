import 'package:flutter/material.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<ReservationNotification>> _futureNotifications;

  @override
  void initState() {
    super.initState();
    _futureNotifications = NotificationService.listUpcoming(horas: 48);
  }

  Color _statusColor(String estado) {
    switch (estado.toUpperCase()) {
      case "APROBADA":
        return Colors.green;
      case "PENDIENTE":
        return Colors.orange;
      case "RECHAZADA":
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _statusIcon(String estado) {
    switch (estado.toUpperCase()) {
      case "APROBADA":
        return Icons.check_circle;
      case "PENDIENTE":
        return Icons.hourglass_bottom;
      case "RECHAZADA":
        return Icons.cancel;
      default:
        return Icons.notifications_active;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FutureBuilder<List<ReservationNotification>>(
        future: _futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tienes notificaciones"));
          }

          final notifs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifs.length,
            itemBuilder: (context, index) {
              final n = notifs[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(n.estado).withOpacity(0.15),
                    child: Icon(
                      _statusIcon(n.estado),
                      color: _statusColor(n.estado),
                    ),
                  ),
                  title: Text(
                    "Reserva en ${n.area}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "${n.fecha} • ${n.horaInicio} - ${n.horaFin}\nEstado: ${n.estado}",
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
