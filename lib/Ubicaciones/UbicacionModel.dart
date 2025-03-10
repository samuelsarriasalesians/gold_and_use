class UbicacionModel {
  final int id;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;

  UbicacionModel({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
  });

  // Convierte el mapa a un objeto de la clase Ubicación
  factory UbicacionModel.fromMap(Map<String, dynamic> map) {
    return UbicacionModel(
      id: map['id'],
      nombre: map['nombre'],
      direccion: map['direccion'],
      latitud: map['latitud'],
      longitud: map['longitud'],
    );
  }

  // Convierte un objeto de la clase Ubicación a un mapa para insertar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}
