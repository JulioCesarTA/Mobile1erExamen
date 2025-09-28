import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final void Function(int) onSelectTab;
  const DashboardScreen({super.key, required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 16;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bienvenido a Smart Condominium",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Haz tu reserva de áreas sociales y administra tus expensas aquí.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Atajos rápidos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // 👇 CAMBIO: usa builder + mainAxisExtent para dar altura fija a cada card
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent:
                  120, // 👈 hace las celdas más altas (sin overflow)
            ),
            itemBuilder: (_, i) {
              switch (i) {
                case 0:
                  return _ShortcutCard(
                    icon: Icons.account_balance_wallet,
                    title: "Mis expensas",
                    color: Colors.orange,
                    onTap: () => onSelectTab(1),
                  );
                case 1:
                  return _ShortcutCard(
                    icon: Icons.event_available,
                    title: "Reservar áreas",
                    color: Colors.green,
                    onTap: () => onSelectTab(2),
                  );
                case 2:
                  return _ShortcutCard(
                    icon: Icons.campaign_outlined,
                    title: "Avisos",
                    color: Colors.indigo,
                    onTap: () => onSelectTab(3),
                  );
                default:
                  return _ShortcutCard(
                    icon: Icons.notifications_active,
                    title: "Notificaciones",
                    color: Colors.redAccent,
                    onTap: () => onSelectTab(4),
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withOpacity(0.08),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // 👈 ayuda si el texto crece
            children: [
              Icon(icon, size: 36, color: color), // 👈 un poco más chico
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2, // 👈 limita líneas para evitar desbordes
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
