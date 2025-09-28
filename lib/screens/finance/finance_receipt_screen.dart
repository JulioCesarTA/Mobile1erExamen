import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/payments_service.dart';

class FinanceReceiptScreen extends StatefulWidget {
  final String chargeId; // id del Charge
  const FinanceReceiptScreen({super.key, required this.chargeId});

  @override
  State<FinanceReceiptScreen> createState() => _FinanceReceiptScreenState();
}

class _FinanceReceiptScreenState extends State<FinanceReceiptScreen> {
  late Future<String?> _future;

  @override
  void initState() {
    super.initState();
    _future = PaymentsService.getReceiptUrlForCharge(widget.chargeId);
  }

  void _refresh() {
    setState(() {
      _future = PaymentsService.getReceiptUrlForCharge(widget.chargeId);
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el recibo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comprobante"),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<String?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error al obtener el comprobante',
                      style: tt.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snap.error}',
                      style: tt.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final receiptUrl = snap.data;
          if (receiptUrl == null || receiptUrl.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_empty, size: 48, color: cs.primary),
                      const SizedBox(height: 12),
                      Text('Tu pago está procesándose', style: tt.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        'Aún no tenemos el link del comprobante. Pulsa “Reintentar” en unos segundos.',
                        style: tt.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 48,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(height: 12),
                    Text('Pago confirmado', style: tt.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Tu comprobante está listo para ver o guardar.',
                      style: tt.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openUrl(receiptUrl),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Abrir recibo'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: receiptUrl),
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enlace copiado')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar enlace'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
