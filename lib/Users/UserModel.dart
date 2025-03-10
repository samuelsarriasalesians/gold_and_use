import 'dart:convert';

class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String? telefono;
  final String? direccion;
  final DateTime fechaCreacion;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    this.direccion,
    required this.fechaCreacion,
  });

  // Convertir de un JSON (mapa de datos) a un objeto UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
    );
  }

  // Convertir de un objeto UserModel a un JSON (mapa de datos)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }
}
