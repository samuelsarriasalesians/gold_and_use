class ConsultorModel {
  final int id;
  final String usuarioId;
  final String nombre;
  final double peso;
  final double valor;
  final String? imagenUrl;
  final String? mensaje;
  final DateTime fechaCreacion;

  ConsultorModel({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.peso,
    required this.valor,
    this.imagenUrl,
    this.mensaje,
    required this.fechaCreacion,
  });

  factory ConsultorModel.fromMap(Map<String, dynamic> json) {
    return ConsultorModel(
      id: json['id'],
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      peso: (json['peso'] as num).toDouble(),
      valor: (json['valor'] as num).toDouble(),
      imagenUrl: json['imagen_url'],
      mensaje: json['mensaje'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
    );
  }

  factory ConsultorModel.fromJson(Map<String, dynamic> json) {
    return ConsultorModel(
      id: json['id'],
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      peso: (json['peso'] as num).toDouble(),
      valor: (json['valor'] as num).toDouble(),
      imagenUrl: json['imagen_url'],
      mensaje: json['mensaje'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
    );
  }
}
