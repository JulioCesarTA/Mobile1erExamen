import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/reservation.dart';
import '../../services/reservations_service.dart';
import '../../widgets/skeleton_tile.dart';
import '../../widgets/empty_state.dart';
import 'new_reservation_screen.dart';

class ReservationsListScreen extends StatefulWidget {
  const ReservationsListScreen({super.key});

  @override
  State<ReservationsListScreen> createState() => _ReservationsListScreenState();
}

class _ReservationsListScreenState extends State<ReservationsListScreen> {
  late Future<List<Reservation>> _future;
  String? _paying; // id en proceso

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = ReservationsService.listMyReservations();
    setState(() {});
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pay(Reservation r) async {
    setState(() => _paying = r.id.toString());
    try {
      final url = await ReservationsService.startCheckoutForReservation(r.id);

      // 1) Log para depurar
      debugPrint('🧾 Stripe checkout URL => $url');

      // 2) Validar la URL
      final uri = Uri.tryParse(url);
      final isHttp =
          uri != null &&
          (uri.scheme == 'https' || uri.scheme == 'http') &&
          uri.host.isNotEmpty;
      if (!isHttp) {
        throw Exception('URL de checkout inválida: $url');
      }

      // 3) Abrir en navegador externo
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        throw Exception('No se pudo abrir el navegador.');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Checkout abierto. Completa el pago y vuelve a la app.',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _paying = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 16;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => _reload(),
            child: FutureBuilder<List<Reservation>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPad),
                    itemCount: 6,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: SkeletonTile(),
                    ),
                  );
                }

                if (snap.hasError) {
                  return ListView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text('Error cargando reservas', style: tt.titleMedium),
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

                final items = snap.data ?? const <Reservation>[];
                if (items.isEmpty) {
                  return ListView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
                    children: const [
                      EmptyState(
                        title: "Sin reservas",
                        subtitle: "Reserva un área común para comenzar.",
                        icon: Icons.event_busy,
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPad),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = items[i];
                    final paying = _paying == r.id.toString();

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.meeting_room, color: cs.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(r.areaNombre, style: tt.titleMedium),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_fmtDate(r.fecha)} · ${r.horaInicio}–${r.horaFin}',
                                    style: tt.bodyMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    r.estado,
                                    style: tt.bodySmall!.copyWith(
                                      color:
                                          r.estado.toUpperCase() == 'APROBADA'
                                          ? Colors.green
                                          : cs.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (r.estado.toUpperCase() != 'APROBADA')
                              SizedBox(
                                width: 110,
                                height: 36,
                                child: OutlinedButton(
                                  onPressed: paying ? null : () => _pay(r),
                                  child: paying
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
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // FAB "Nueva"
          Positioned(
            right: 16,
            bottom: 16 + kBottomNavigationBarHeight,
            child: FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NewReservationScreen(),
                  ),
                );
                if (created == true) {
                  _reload(); // 👈 solo recarga si realmente se creó
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Nueva'),
            ),
          ),
        ],
      ),
    );
  }
}
