class TransaccionModel {
  final String id;
  final String usuarioId;
  final String tipo;
  final double cantidad;
  final double precioGramo;
  final double total;
  final DateTime fecha;

  TransaccionModel({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.cantidad,
    required this.precioGramo,
    required this.total,
    required this.fecha,
  });

  // Convertir de un JSON (mapa de datos) a un objeto TransaccionModel
  factory TransaccionModel.fromJson(Map<String, dynamic> json) {
    return TransaccionModel(
      id: json['id'],
      usuarioId: json['usuario_id'],
      tipo: json['tipo'],
      cantidad: json['cantidad'].toDouble(),
      precioGramo: json['precio_gramo'].toDouble(),
      total: json['total'].toDouble(),
      fecha: DateTime.parse(json['fecha']),
    );
  }

  // Convertir de un objeto TransaccionModel a un JSON (mapa de datos)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'tipo': tipo,
      'cantidad': cantidad,
      'precio_gramo': precioGramo,
      'total': total,
      'fecha': fecha.toIso8601String(),
    };
  }
}
