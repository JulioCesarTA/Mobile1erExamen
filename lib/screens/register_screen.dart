import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  void _register() {
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }
    print("Registro con: ${_emailController.text}, ${_passwordController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(controller: _emailController, hint: "Correo"),
            const SizedBox(height: 15),
            CustomTextField(controller: _passwordController, hint: "Contraseña", obscure: true),
            const SizedBox(height: 15),
            CustomTextField(controller: _confirmController, hint: "Confirmar contraseña", obscure: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: const Text("Registrarse")),
          ],
        ),
      ),
    );
  }
}
