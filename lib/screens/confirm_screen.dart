import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';

class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  final _codeController = TextEditingController();

  void _confirm() {
    print("Confirmación con código: ${_codeController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirmar Cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(controller: _codeController, hint: "Código de confirmación"),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _confirm, child: const Text("Confirmar")),
          ],
        ),
      ),
    );
  }
}
