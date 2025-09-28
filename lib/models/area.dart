class Area {
  final int id;
  final String nombre;
  final String? descripcion;
  final int? capacidad;
  final double? precio;
  final String? horarioApertura; // "HH:MM:SS"
  final String? horarioCierre; // "HH:MM:SS"

  Area({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.capacidad,
    this.precio,
    this.horarioApertura,
    this.horarioCierre,
  });

  factory Area.fromJson(Map<String, dynamic> j) => Area(
    id: j['id'] as int,
    nombre: (j['nombre'] ?? '').toString(),
    descripcion: j['descripcion']?.toString(),
    capacidad: j['capacidad'] is int ? j['capacidad'] as int : null,
    precio: j['precio'] != null
        ? double.tryParse(j['precio'].toString())
        : null,
    horarioApertura: j['horario_apertura']?.toString(),
    horarioCierre: j['horario_cierre']?.toString(),
  );
}
