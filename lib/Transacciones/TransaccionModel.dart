class TransaccionModel {
  final int id;
  final String usuarioId;
  final String tipo;
  final double cantidad;
  final double precioGramo;
  final double total;
  final DateTime fecha;
  final String? qrCode;

  TransaccionModel({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.cantidad,
    required this.precioGramo,
    required this.total,
    required this.fecha,
    this.qrCode,
  });

  // Convierte el mapa a un objeto de la clase Transaccion
  factory TransaccionModel.fromMap(Map<String, dynamic> map) {
    return TransaccionModel(
      id: map['id'],
      usuarioId: map['usuario_id'],
      tipo: map['tipo'],
      cantidad: map['cantidad'],
      precioGramo: map['precio_gramo'],
      total: map['total'],
      fecha: DateTime.parse(map['fecha']),
      qrCode: map['qr_code'],
    );
  }

  // Convierte un objeto de la clase Transaccion a un mapa para insertar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'usuario_id': usuarioId,
      'tipo': tipo,
      'cantidad': cantidad,
      'precio_gramo': precioGramo,
      'total': total,
      'fecha': fecha.toIso8601String(),
      'qr_code': qrCode,
    };
  }
}
