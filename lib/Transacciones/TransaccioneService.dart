import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'TransaccionModel.dart';
import '../Users/UserModel.dart'; // Asegúrate de importar tu modelo User

class TransaccionController {
  final SupabaseClient supabase = Supabase.instance.client;
  final Dio _dio = Dio();
  double goldPrice = 86; // Precio por defecto en caso de fallo

  // Obtener todas las transacciones
  Future<List<TransaccionModel>> getTransacciones() async {
    final response = await supabase.from('transacciones').select();
    return response
        .map<TransaccionModel>((json) => TransaccionModel.fromJson(json))
        .toList();
  }

  // Obtener una transacción por ID
  Future<TransaccionModel?> getTransaccionById(String id) async {
    final response = await supabase.from('transacciones').select().eq('id', id).single();
    return response != null ? TransaccionModel.fromJson(response) : null;
  }

  // Crear una nueva transacción
  Future<void> createTransaccion(TransaccionModel transaccion) async {
    await supabase.from('transacciones').insert(transaccion.toJson());
  }

  // Eliminar una transacción
  Future<void> deleteTransaccion(String id) async {
    await supabase.from('transacciones').delete().eq('id', id);
  }

  // Subir una imagen a Storage (carpeta = id del usuario)
  Future<String?> uploadImage(File imageFile, UserModel user) async {
    try {
      final folderName = user.id; // Carpeta: ID del usuario
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg'; // Nombre único
      final fullPath = '$folderName/$fileName'; // Carpeta + nombre

      final response = await supabase.storage
          .from('consultorimage') // Asegúrate de que se llame exactamente así
          .upload(fullPath, imageFile);

      if (response.isNotEmpty) {
        // Imagen subida correctamente, devolvemos la URL pública
        final publicUrl = supabase.storage.from('consultorimage').getPublicUrl(fullPath);
        return publicUrl;
      } else {
        print('Error al subir la imagen: respuesta vacía o nula');
        return null;
      }
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  // Guardar la información de la imagen en la base de datos
  Future<void> saveImageData(String userId, String imageUrl) async {
    try {
      await supabase.from('imagenes').insert({
        'usuario_id': userId,
        'imagen_url': imageUrl,
      });
    } catch (e) {
      print('Error al guardar los datos de la imagen: $e');
    }
  }

  // Obtener el precio del oro en tiempo real
  Future<void> fetchGoldPrice() async {
    try {
      final response = await _dio.get(
        'https://api.kinesis.money/v1/market-data/gold',
        options: Options(headers: {
          'Authorization': 'Bearer D03C5577C7A841389CCB91C5BD58B91F'
        }),
      );

      if (response.statusCode == 200) {
        goldPrice = response.data['price'];
      }
    } catch (e) {
      print("Error obteniendo el precio del oro: $e");
    }
  }

  // Convertir unidades de peso
  double convertWeight(double weight, String weightUnit) {
    switch (weightUnit) {
      case 'kg':
        return weight * 1000;
      case 'oz':
        return weight * 31.1035;
      case 'lb':
        return weight * 453.592;
      default:
        return weight; // Asume gramos
    }
  }

  // Calcular el precio del oro en función del peso y la pureza
  double calculateGoldPrice(double weight, String purity, String weightUnit) {
    double purityValue;
    switch (purity) {
      case '24K':
        purityValue = 1000;
        break;
      case '18K':
        purityValue = 750;
        break;
      case '12K':
        purityValue = 500;
        break;
      default:
        purityValue = double.tryParse(purity.replaceAll('K', '')) ?? 1000;
        break;
    }
    double weightInGrams = convertWeight(weight, weightUnit);
    return ((weightInGrams * (goldPrice * purityValue / 1000)) - 5) * 0.94;
  }
}
