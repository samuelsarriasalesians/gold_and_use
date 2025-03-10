class NotificacionModel {
  final int id;
  final String usuarioId;
  final String mensaje;
  final bool leido;
  final DateTime fecha;

  NotificacionModel({
    required this.id,
    required this.usuarioId,
    required this.mensaje,
    required this.leido,
    required this.fecha,
  });

  // Convierte el mapa a un objeto de la clase Notificación
  factory NotificacionModel.fromMap(Map<String, dynamic> map) {
    return NotificacionModel(
      id: map['id'],
      usuarioId: map['usuario_id'],
      mensaje: map['mensaje'],
      leido: map['leido'] ?? false,
      fecha: DateTime.parse(map['fecha']),
    );
  }

  // Convierte un objeto de la clase Notificación a un mapa para insertar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'usuario_id': usuarioId,
      'mensaje': mensaje,
      'leido': leido,
      'fecha': fecha.toIso8601String(),
    };
  }
}
