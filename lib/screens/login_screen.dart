import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'confirm_screen.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    // Aquí conectas con Django
    print("Login con: ${_emailController.text}, ${_passwordController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(controller: _emailController, hint: "Correo"),
            const SizedBox(height: 15),
            CustomTextField(controller: _passwordController, hint: "Contraseña", obscure: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Ingresar")),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              child: const Text("¿No tienes cuenta? Regístrate"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfirmScreen()));
              },
              child: const Text("Confirmar cuenta"),
            ),
          ],
        ),
      ),
    );
  }
}
