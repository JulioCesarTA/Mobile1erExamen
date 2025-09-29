import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../home/dashboard_screen.dart';
import '../reservations/reservations_list_screen.dart';
import '../finance/finance_list_screen.dart';
import '../notices/notices_list_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selected = 0;
  Map<String, dynamic>? _user;

  void _onSelectTab(int i) => setState(() => _selected = i);

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ApiService.getCurrentUser();
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      "Smart Condominium",
      "Finanzas",
      "Reservas",
      "Avisos",
      "Notificaciones",
    ];
    final pages = [
      DashboardScreen(onSelectTab: _onSelectTab),
      const FinanceListScreen(),
      const ReservationsListScreen(),
      const NoticesListScreen(),
      const NotificationsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selected]),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
            onSelected: (v) {
              if (v == 'logout') _logout();
            },
            itemBuilder: (context) => [
              if (_user != null) ...[
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_user!['first_name']} ${_user!['last_name']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _user!['role'] ?? 'Sin rol',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _user!['email'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
              ],
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: pages[_selected],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selected,
        onTap: _onSelectTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Finanzas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            label: 'Avisos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: 'Notifs',
          ),
        ],
      ),
    );
  }
}
