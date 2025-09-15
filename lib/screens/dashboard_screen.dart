import 'package:flutter/material.dart';
import '../services/api_service.dart';

// Páginas
import 'home_screen.dart';
import 'notices_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

enum AppRoute {
  dashboard,   // Inicio
  notices,     // Avisos
  reports,     // Gestionar Reportes
  security,    // Gestionar Seguridad
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _miniDrawer = false;

  AppRoute _route = AppRoute.dashboard;

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

  String _titleFor(AppRoute r) {
    switch (r) {
      case AppRoute.notices:
        return 'Avisos';
      case AppRoute.reports:
        return 'Gestionar Reportes';
      case AppRoute.security:
        return 'Gestionar Seguridad';
      case AppRoute.dashboard:
      default:
        return 'Inicio';
    }
  }

  Widget _screenFor(AppRoute r) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    switch (r) {
      case AppRoute.notices:
        return const NoticesScreen();
      case AppRoute.reports:
        return const _PlaceholderPage(title: 'Gestionar Reportes');
      case AppRoute.security:
        return const _PlaceholderPage(title: 'Gestionar Seguridad');
      case AppRoute.dashboard:
      default:
        return HomeScreen(user: _user);
    }
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();
  void _go(AppRoute r) {
    setState(() => _route = r);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawerScrimColor: Colors.black.withOpacity(0.28),
      drawer: _AppDrawer(
        user: _user,
        mini: _miniDrawer,
        onToggleMini: (v) => setState(() => _miniDrawer = v),
        current: _route,
        onGo: _go,
        onLogout: () {
          Navigator.pop(context);
          _logout();
        },
      ),
      appBar: AppBar(
        title: Text(_titleFor(_route)),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: _openDrawer),
      ),
      body: _screenFor(_route),
    );
  }
}

/// Drawer (sin Áreas/Reservas, pero con la carpeta “Gestión Propiedades”)
class _AppDrawer extends StatefulWidget {
  const _AppDrawer({
    required this.user,
    required this.mini,
    required this.onToggleMini,
    required this.current,
    required this.onGo,
    required this.onLogout,
  });

  final Map<String, dynamic>? user;
  final bool mini;
  final ValueChanged<bool> onToggleMini;
  final AppRoute current;
  final ValueChanged<AppRoute> onGo;
  final VoidCallback onLogout;

  @override
  State<_AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<_AppDrawer> {
  final Map<String, bool> _open = {
    'avisos'      : true,
    'propiedades' : false, // << carpeta pedida
    'reportes'    : false,
    'seguridad'   : false,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = widget.mini ? 92.0 : 280.0;

    final fullName = [
      (widget.user?['first_name'] ?? '').toString().trim(),
      (widget.user?['last_name'] ?? '').toString().trim(),
    ].where((e) => e.isNotEmpty).join(' ');
    final email = (widget.user?['email'] ?? '').toString();
    final role = (widget.user?['role'] ?? '').toString();

    return Drawer(
      width: width,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header + toggler mini
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  if (!widget.mini)
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: cs.primary,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fullName.isNotEmpty ? fullName : email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(role.isEmpty ? '—' : role,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 8),
                  Tooltip(
                    message: widget.mini ? 'Expandir' : 'Contraer',
                    child: IconButton(
                      onPressed: () => widget.onToggleMini(!widget.mini),
                      icon: Icon(widget.mini ? Icons.chevron_right : Icons.chevron_left),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Divider(height: 1),

            // Inicio
            _DrawerButton(
              mini: widget.mini,
              icon: Icons.home_outlined,
              label: 'Inicio',
              selected: widget.current == AppRoute.dashboard,
              onTap: () => widget.onGo(AppRoute.dashboard),
            ),

            // Gestionar Avisos
            _SectionHeader(
              mini: widget.mini,
              icon: Icons.campaign_outlined,
              label: 'Gestionar Avisos',
              open: _open['avisos']!,
              onToggle: () => setState(() => _open['avisos'] = !_open['avisos']!),
            ),
            if (_open['avisos']! && !widget.mini)
              _DrawerButton(
                mini: widget.mini,
                depth: 1,
                icon: Icons.notifications_none_rounded,
                label: 'Avisos',
                selected: widget.current == AppRoute.notices,
                onTap: () => widget.onGo(AppRoute.notices),
              ),

            // Gestión Propiedades (solo la carpeta, sin subitems)
            _SectionHeader(
              mini: widget.mini,
              icon: Icons.home_work_outlined,
              label: 'Gestión Propiedades',
              open: _open['propiedades']!,
              onToggle: () => setState(() => _open['propiedades'] = !_open['propiedades']!),
            ),

            // Gestionar Reportes
            _SectionHeader(
              mini: widget.mini,
              icon: Icons.description_outlined,
              label: 'Gestionar Reportes',
              open: _open['reportes']!,
              onToggle: () => setState(() => _open['reportes'] = !_open['reportes']!),
            ),

            // Gestionar Seguridad
            _SectionHeader(
              mini: widget.mini,
              icon: Icons.shield_outlined,
              label: 'Gestionar Seguridad',
              open: _open['seguridad']!,
              onToggle: () => setState(() => _open['seguridad'] = !_open['seguridad']!),
            ),

            const Spacer(),
            const Divider(height: 1),

            // Logout
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
              child: widget.mini
                  ? Tooltip(
                      message: 'Cerrar sesión',
                      child: IconButton(
                        onPressed: widget.onLogout,
                        icon: const Icon(Icons.logout),
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.mini,
    required this.icon,
    required this.label,
    required this.open,
    required this.onToggle,
  });

  final bool mini;
  final IconData icon;
  final String label;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onToggle,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: mini ? 0 : 12, vertical: 10),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(icon, color: cs.onSurfaceVariant),
              if (!mini) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Icon(open ? Icons.remove : Icons.add, size: 18, color: cs.onSurfaceVariant),
              ],
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerButton extends StatelessWidget {
  const _DrawerButton({
    required this.mini,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.depth = 0,
  });

  final bool mini;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = selected ? cs.primaryContainer.withOpacity(0.65) : Colors.transparent;
    final ic = selected ? cs.primary : cs.onSurfaceVariant;
    final tx = selected ? cs.primary : cs.onSurface;
    final leftPad = mini ? 0.0 : (depth == 0 ? 12.0 : 28.0);

    final child = Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: leftPad, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(icon, color: ic, size: 24),
          if (!mini) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: tx)),
            ),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle)),
            ),
          ],
          const SizedBox(width: 6),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: mini
          ? Tooltip(message: label, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: SizedBox(height: 46, child: child)))
          : InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: child),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: Theme.of(context).textTheme.headlineSmall));
  }
}
