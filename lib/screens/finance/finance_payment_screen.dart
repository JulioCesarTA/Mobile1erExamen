import 'package:flutter/material.dart';
import '../../services/finance_service.dart';
import '../../widgets/primary_button.dart';

class FinancePaymentScreen extends StatefulWidget {
  final String paymentId;
  final String concept;
  final double amount;

  const FinancePaymentScreen({
    super.key,
    required this.paymentId,
    required this.concept,
    required this.amount,
  });

  @override
  State<FinancePaymentScreen> createState() => _FinancePaymentScreenState();
}

class _FinancePaymentScreenState extends State<FinancePaymentScreen> {
  bool _loading = false;
  String? _receiptId;

  Future<void> _pay() async {
    setState(() => _loading = true);
    try {
      final receiptId = await FinanceService.payPayment(widget.paymentId);
      setState(() => _receiptId = receiptId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pago realizado con éxito')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pagar")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(widget.concept),
                subtitle: const Text("Método: (configurar gateway)"),
                trailing: Text("Bs. ${widget.amount.toStringAsFixed(2)}"),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: _receiptId == null ? 'Pagar ahora' : 'Ver comprobante',
              loading: _loading,
              onPressed: () {
                if (_receiptId == null) {
                  _pay();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
