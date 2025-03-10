class InversionModel {
  final int id;
  final String usuarioId;
  final double cantidad;
  final double rendimiento;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String estado;

  InversionModel({
    required this.id,
    required this.usuarioId,
    required this.cantidad,
    required this.rendimiento,
    required this.fechaInicio,
    this.fechaFin,
    required this.estado,
  });

  // Convierte el mapa a un objeto de la clase Inversión
  factory InversionModel.fromMap(Map<String, dynamic> map) {
    return InversionModel(
      id: map['id'],
      usuarioId: map['usuario_id'],
      cantidad: map['cantidad'],
      rendimiento: map['rendimiento'],
      fechaInicio: DateTime.parse(map['fecha_inicio']),
      fechaFin: map['fecha_fin'] != null ? DateTime.parse(map['fecha_fin']) : null,
      estado: map['estado'],
    );
  }

  // Convierte un objeto de la clase Inversión a un mapa para insertar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'usuario_id': usuarioId,
      'cantidad': cantidad,
      'rendimiento': rendimiento,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'estado': estado,
    };
  }
}
