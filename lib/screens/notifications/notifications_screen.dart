import 'package:flutter/material.dart';
import '../../services/notifications_service.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const EmptyState(
          title: "Notificaciones en tiempo real",
          subtitle:
              "Aquí verás alertas de incidentes (IA), accesos no autorizados, etc.",
          icon: Icons.notifications_active,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            await NotificationsService.simulateIncident();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simulación de incidente recibida'),
                ),
              );
            }
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text("Probar notificación (stub)"),
        ),
      ],
    );
  }
}
