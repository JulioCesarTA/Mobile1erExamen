// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'notices_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  int _selectedIndex = 0; // 0: Resumen, 1: Avisos

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Estado del Drawer (expandido/compacto)
  bool _miniDrawer = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loggedIn = await ApiService.isLoggedIn();
    if (!loggedIn) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      return;
    }
    final user = await ApiService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  String _titleFor(int index) {
    switch (index) {
      case 1:
        return 'Avisos';
      case 0:
      default:
        return 'Dashboard';
    }
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _selectTab(int i) {
    setState(() => _selectedIndex = i);
    Navigator.of(context).maybePop(); // cierra el Drawer si está abierto
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : IndexedStack(
            index: _selectedIndex,
            children: [
              _ProfilePanel(user: _user),
              const NoticesScreen(),
            ],
          );

    return Scaffold(
      key: _scaffoldKey,
      // Drawer "overlay" — NO empuja el contenido
      drawerScrimColor: Colors.black.withOpacity(0.28),
      drawer: _AppDrawer(
        user: _user,
        mini: _miniDrawer,
        onToggleMini: (v) => setState(() => _miniDrawer = v),
        selectedIndex: _selectedIndex,
        onSelect: _selectTab,
        onLogout: () {
          Navigator.pop(context); // cierra el drawer
          _logout();
        },
      ),
      appBar: AppBar(
        title: Text(_titleFor(_selectedIndex)),
        // Ícono de menú para abrir el drawer
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _openDrawer,
          tooltip: 'Menú',
        ),
      ),
      body: body,
    );
  }
}

/// Drawer personalizado: overlay, compacto/expandido, logout abajo.
class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.user,
    required this.mini,
    required this.onToggleMini,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  final Map<String, dynamic>? user;
  final bool mini;
  final ValueChanged<bool> onToggleMini;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = mini ? 92.0 : 280.0;

    final fullName = [
      (user?['first_name'] ?? '').toString().trim(),
      (user?['last_name'] ?? '').toString().trim(),
    ].where((e) => e.isNotEmpty).join(' ');
    final email = (user?['email'] ?? '').toString();

    return Drawer(
      width: width,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Toggler mini/expandido
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  if (!mini)
                    Expanded(
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 16, child: Icon(Icons.person)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              fullName.isNotEmpty ? fullName : email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 8),
                  Tooltip(
                    message: mini ? 'Expandir' : 'Contraer',
                    child: IconButton(
                      onPressed: () => onToggleMini(!mini),
                      icon: Icon(mini ? Icons.chevron_right : Icons.chevron_left),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Divider(height: 1),

            // Items
            _DrawerItem(
              mini: mini,
              icon: Icons.home_outlined,
              label: 'Resumen',
              selected: selectedIndex == 0,
              onTap: () => onSelect(0),
            ),
            _DrawerItem(
              mini: mini,
              icon: Icons.campaign_outlined,
              label: 'Avisos',
              selected: selectedIndex == 1,
              onTap: () => onSelect(1),
            ),

            const Spacer(),
            const Divider(height: 1),

            // Logout abajo
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
              child: mini
                  ? Tooltip(
                      message: 'Cerrar sesión',
                      child: IconButton(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout),
                        color: cs.error,
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.error,
                          side: BorderSide(color: cs.outlineVariant),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.mini,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final bool mini;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = selected ? cs.primaryContainer.withOpacity(0.6) : Colors.transparent;
    final ic = selected ? cs.primary : cs.onSurfaceVariant;
    final tx = selected ? cs.primary : cs.onSurface;

    final child = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: mini ? 0 : 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(icon, color: ic, size: 26),
          if (!mini) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: tx,
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: mini
          ? Tooltip(
              message: label,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: SizedBox(height: 48, child: child),
              ),
            )
          : InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: child,
            ),
    );
  }
}

// Panel "Resumen" (igual al tuyo, encapsulado y sin cambios de lógica)
class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.user});

  final Map<String, dynamic>? user;

  @override
  Widget build(BuildContext context) {
    final String roleRaw = (user?['role']?.toString().trim() ?? '');
    final String role = roleRaw.isEmpty ? '—' : roleRaw;
    final String email = (user?['email']?.toString() ?? '');
    final String fullName = [
      (user?['first_name'] ?? '').toString().trim(),
      (user?['last_name'] ?? '').toString().trim(),
    ].where((e) => e.isNotEmpty).join(' ');
    final List<String> extraPermissions =
        ((user?['extra_permissions'] as List?) ?? [])
            .map((e) => e.toString())
            .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                runSpacing: 10,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName.isEmpty ? email : fullName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              email,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Text(
                        'Rol: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(role),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Permisos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (extraPermissions.isEmpty)
                    const Text('—')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: extraPermissions
                          .map((p) => Chip(label: Text(p)))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
