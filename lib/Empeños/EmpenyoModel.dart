class EmpenyoModel {
  final int id;
  final String usuarioId;
  final double cantidad;
  final double valorEstimado;
  final double tasaInteres;
  final int plazoDias;
  final DateTime fechaEmpenyo;
  final DateTime? fechaVencimiento;
  final String estado;
  final String? mediaId;

  EmpenyoModel({
    required this.id,
    required this.usuarioId,
    required this.cantidad,
    required this.valorEstimado,
    required this.tasaInteres,
    required this.plazoDias,
    required this.fechaEmpenyo,
    this.fechaVencimiento,
    required this.estado,
    this.mediaId,
  });

  // Convierte el mapa a un objeto de la clase Empeño
  factory EmpenyoModel.fromMap(Map<String, dynamic> map) {
    return EmpenyoModel(
      id: map['id'],
      usuarioId: map['usuario_id'],
      cantidad: map['cantidad'],
      valorEstimado: map['valor_estimado'],
      tasaInteres: map['tasa_interes'],
      plazoDias: map['plazo_dias'],
      fechaEmpenyo: DateTime.parse(map['fecha_empeno']),
      fechaVencimiento: map['fecha_vencimiento'] != null
          ? DateTime.parse(map['fecha_vencimiento'])
          : null,
      estado: map['estado'],
      mediaId: map['media_id'],
    );
  }

  // Convierte un objeto de la clase Empeño a un mapa para insertar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'usuario_id': usuarioId,
      'cantidad': cantidad,
      'valor_estimado': valorEstimado,
      'tasa_interes': tasaInteres,
      'plazo_dias': plazoDias,
      'fecha_empeno': fechaEmpenyo.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
      'estado': estado,
      'media_id': mediaId,
    };
  }
}
