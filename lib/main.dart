import 'dart:async';
import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/notification_helper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1) Inicializar notificaciones locales (permisos + canal)
  await initLocalNotifications();
  runApp(const SmartCondominiumApp());
}

class SmartCondominiumApp extends StatelessWidget {
  const SmartCondominiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Condominium',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(), // 👈 tu theme central
      builder: (context, child) {
        final media = MediaQuery.of(context);
        // Evita letras gigantes por accesibilidad del sistema
        return MediaQuery(
          data: media.copyWith(
            textScaleFactor: media.textScaleFactor.clamp(0.85, 1.15),
          ),
          child: child!,
        );
      },
      home: const _Gate(),
    );
  }
}

class _Gate extends StatefulWidget {
  const _Gate({super.key});
  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  late Future<bool> _future;
  bool _notifiedOnce = false; // evita notificar múltiples veces al reconstruir

  @override
  void initState() {
    super.initState();
    _future = ApiService.isLoggedIn();
  }

  Future<void> _notifyUpcomingOnce() async {
    if (_notifiedOnce) return;
    _notifiedOnce = true;

    try {
      // Pide reservas próximas (48h). Ajusta si quieres otro horizonte.
      final notifs = await NotificationService.listUpcoming(horas: 48);

      // Muestra hasta 3 notificaciones para no “spamear”
      for (final n in notifs.take(3)) {
        await showReservationNotification(
          id: n.id,
          area: n.area,
          fecha: n.fecha,
          hora: n.horaInicio,
        );
      }
    } catch (_) {
      // Silenciar errores de red aquí para no romper el flujo de arranque.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final logged = snap.data ?? false;

        if (logged) {
          // Disparamos la consulta y notificación una sola vez,
          // después del primer frame (evita hacerlo dentro del build sincrónico).
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _notifyUpcomingOnce();
          });
        }

        return logged ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
