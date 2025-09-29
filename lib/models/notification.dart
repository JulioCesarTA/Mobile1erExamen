class ReservationNotification {
  final int id;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String area;
  final String estado;

  ReservationNotification({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.area,
    required this.estado,
  });

  factory ReservationNotification.fromJson(Map<String, dynamic> json) {
    return ReservationNotification(
      id: json['id'] as int,
      fecha: json['fecha'] ?? '',
      horaInicio: json['hora_inicio'] ?? '',
      horaFin: json['hora_fin'] ?? '',
      area: json['area'] ?? '',
      estado: json['estado'] ?? '',
    );
  }
}
