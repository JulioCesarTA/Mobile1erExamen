import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/area.dart';
import '../../services/reservations_service.dart';

class NewReservationScreen extends StatefulWidget {
  const NewReservationScreen({super.key});

  @override
  State<NewReservationScreen> createState() => _NewReservationScreenState();
}

class _NewReservationScreenState extends State<NewReservationScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Area> _areas = [];
  Area? _area;
  DateTime? _fecha;
  TimeOfDay? _inicio;
  TimeOfDay? _fin;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    try {
      final list = await ReservationsService.listAreas();
      if (!mounted) return;
      setState(() => _areas = list);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando áreas: $e')));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _pickTimeStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _inicio ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _inicio = picked);
  }

  Future<void> _pickTimeEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _fin ??
          (_inicio != null
              ? _inicio!.replacing(minute: (_inicio!.minute + 60) % 60)
              : TimeOfDay.now()),
    );
    if (picked != null) setState(() => _fin = picked);
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (_area == null || _fecha == null || _inicio == null || _fin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos.')),
      );
      return;
    }
    // Validación básica: inicio < fin
    final iniMins = _inicio!.hour * 60 + _inicio!.minute;
    final finMins = _fin!.hour * 60 + _fin!.minute;
    if (finMins <= iniMins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora fin debe ser mayor a la hora inicio.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final r = await ReservationsService.createReservation(
        areaId: _area!.id,
        fecha: _fecha!,
        horaInicio: _inicio!,
        horaFin: _fin!,
      );

      // (opcional) ir a Stripe:
      final url = await ReservationsService.startCheckoutForReservation(r.id);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva creada. Se abrió el pago.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva reserva')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<Area>(
                isExpanded: true,
                value: _area,
                items: _areas
                    .map(
                      (a) => DropdownMenuItem(value: a, child: Text(a.nombre)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _area = v),
                decoration: const InputDecoration(
                  labelText: 'Área común',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _fecha == null
                            ? 'Elegir fecha'
                            : '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTimeStart,
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        _inicio == null
                            ? 'Hora inicio'
                            : _inicio!.format(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTimeEnd,
                      icon: const Icon(Icons.schedule_send),
                      label: Text(
                        _fin == null ? 'Hora fin' : _fin!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_area?.precio != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Precio: Bs. ${_area!.precio!.toStringAsFixed(2)}',
                    style: tt.titleMedium,
                  ),
                ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Reservar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
