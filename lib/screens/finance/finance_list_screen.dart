// lib/screens/finance/finance_list_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/payment.dart';
import '../../services/charges_service.dart';
import '../../widgets/skeleton_tile.dart';
import '../../widgets/empty_state.dart';
import 'finance_receipt_screen.dart';

class FinanceListScreen extends StatefulWidget {
  const FinanceListScreen({super.key});
  @override
  State<FinanceListScreen> createState() => _FinanceListScreenState();
}

class _FinanceListScreenState extends State<FinanceListScreen> {
  late Future<List<Payment>> _future;
  Map<String, dynamic>? _summary;
  String? _payingId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = ChargesService.listMine(onlyOpen: false); // pagados + pendientes
    _loadSummary();
    setState(() {});
  }

  Future<void> _loadSummary() async {
    try {
      final s = await ChargesService.summaryMine(onlyOpen: true);
      if (!mounted) return;
      setState(() => _summary = s);
    } catch (_) {}
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _startPayment(Payment p) async {
    setState(() => _payingId = p.id);
    try {
      final url = await ChargesService.startCheckoutForCharge(p.id);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Checkout abierto. Completa el pago y vuelve a la app.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _payingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Padding inferior = SafeArea + altura de la barra inferior para no quedar por debajo
    final bottomPad =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 16;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Payment>>(
          future: _future,
          builder: (context, snap) {
            // LOADING
            if (snap.connectionState != ConnectionState.done) {
              return ListView.builder(
                padding: EdgeInsets.fromLTRB(8, 8, 8, bottomPad),
                itemCount: 1 + 6,
                itemBuilder: (_, index) {
                  if (index == 0) return _SummaryHeader(summary: _summary);
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: SkeletonTile(),
                  );
                },
              );
            }

            // ERROR
            if (snap.hasError) {
              return ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error cargando expensas', style: tt.titleMedium),
                  const SizedBox(height: 6),
                  Text('${snap.error}', style: tt.bodyMedium),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              );
            }

            final items = snap.data ?? const <Payment>[];

            // VACÍO
            if (items.isEmpty) {
              return ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
                children: const [
                  _SummaryHeader(),
                  SizedBox(height: 8),
                  EmptyState(
                    title: "No tienes pagos",
                    subtitle:
                        "Cuando la administración emita expensas, aparecerán aquí.",
                    icon: Icons.receipt_long,
                  ),
                ],
              );
            }

            // LISTA
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(8, 8, 8, bottomPad),
              itemCount: 1 + items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, index) {
                if (index == 0) return _SummaryHeader(summary: _summary);
                final p = items[index - 1];

                return Card(
                  child: InkWell(
                    onTap: () {
                      if (p.paid) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FinanceReceiptScreen(chargeId: p.id),
                          ),
                        );
                      } else {
                        _startPayment(p);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            p.paid ? Icons.check_circle : Icons.pending_actions,
                            color: p.paid ? Colors.green : cs.primary,
                          ),
                          const SizedBox(width: 12),

                          // Título + subtítulo (ocupa el espacio flexible)
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.concept, style: tt.bodyLarge),
                                const SizedBox(height: 2),
                                Text(
                                  p.paid
                                      ? "Pagado"
                                      : (p.dueDate != null
                                            ? "Vence: ${_fmtDate(p.dueDate)}"
                                            : "Pendiente"),
                                  style: tt.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Monto + botón (sin restricciones de ListTile)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Bs. ${p.amount.toStringAsFixed(2)}",
                                style: tt.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              if (!p.paid)
                                SizedBox(
                                  width: 100,
                                  height: 36,
                                  child: OutlinedButton(
                                    onPressed: _payingId == p.id
                                        ? null
                                        : () => _startPayment(p),
                                    child: _payingId == p.id
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Pagar'),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final Map<String, dynamic>? summary;
  const _SummaryHeader({this.summary});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (summary == null) return const SizedBox.shrink();
    final open = (summary!['open'] as Map<String, dynamic>?);
    if (open == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Pendiente: Bs. ${open['amount'] ?? '0.00'}  ·  ${open['count'] ?? 0} cargos',
        style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
      ),
    );
  }
}
