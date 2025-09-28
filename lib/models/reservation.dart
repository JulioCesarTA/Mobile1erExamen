class Reservation {
  final int id;
  final int areaId;
  final String areaNombre;
  final DateTime fecha; // fecha_reserva
  final String horaInicio; // "HH:mm" o "HH:mm:ss"
  final String horaFin; // idem
  final String estado; // PENDIENTE / APROBADA / etc.

  Reservation({
    required this.id,
    required this.areaId,
    required this.areaNombre,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
  });

  factory Reservation.fromJson(Map<String, dynamic> j) {
    final fechaStr = (j['fecha_reserva'] ?? j['fecha'] ?? '').toString();
    final areaNombre =
        (j['area_nombre'] ?? j['area_name'] ?? j['area']?['nombre'] ?? '')
            .toString();
    final areaId = j['area_id'] ?? j['area'];
    return Reservation(
      id: (j['id'] ?? 0) as int,
      areaId: areaId is int ? areaId : int.tryParse(areaId.toString()) ?? 0,
      areaNombre: areaNombre,
      fecha: DateTime.tryParse(fechaStr) ?? DateTime.now(),
      horaInicio: (j['hora_inicio'] ?? '').toString(),
      horaFin: (j['hora_fin'] ?? '').toString(),
      estado: (j['estado'] ?? '').toString(),
    );
  }
}
