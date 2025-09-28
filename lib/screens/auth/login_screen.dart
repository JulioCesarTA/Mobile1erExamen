// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart'; // 👈 navega al contenedor con navbar

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final result = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      debugPrint("✅ Login exitoso: $result");
      if (!mounted) return;

      // 👇 Navegación “limpia”: borra el stack y entra a HomeScreen con el theme ya aplicado
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint("❌ Error en login: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      // Deja que el Theme maneje los colores de fondo; si quieres forzar:
      // backgroundColor: cs.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: cs.surface,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.apartment_rounded, size: 72, color: cs.primary),
                    const SizedBox(height: 12),
                    Text(
                      "Smart Condominium",
                      style: tt.headlineSmall, // usa tamaños del theme
                    ),
                    const SizedBox(height: 24),

                    // Correo
                    CustomTextField(
                      controller: _emailController,
                      hint: "Correo",
                    ),
                    const SizedBox(height: 12),

                    // Contraseña
                    CustomTextField(
                      controller: _passwordController,
                      hint: "Contraseña",
                      obscure: true,
                    ),
                    const SizedBox(height: 20),

                    // Botón login (usa el estilo global del theme)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Ingresar"),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "Administra tu condominio de forma simple y segura",
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium, // gris suave definido en theme
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
