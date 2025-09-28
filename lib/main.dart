// lib/main.dart
import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'services/api_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartCondominiumApp());
}

class SmartCondominiumApp extends StatelessWidget {
  const SmartCondominiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Condominium',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(), // 👈 usa tu theme central
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

  @override
  void initState() {
    super.initState();
    _future = ApiService.isLoggedIn();
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
        return logged ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
