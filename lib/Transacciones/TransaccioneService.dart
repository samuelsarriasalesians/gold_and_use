import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'TransaccionModel.dart';

class TransaccionController {
  final SupabaseClient supabase = Supabase.instance.client;

  final Dio _dio = Dio();

  double goldPrice = 86; // Precio por defecto en caso de fallo

  // Obtener todas las transacciones
  Future<List<TransaccionModel>> getTransacciones() async {
    final response = await supabase.from('transacciones').select();

    return response
        .map<TransaccionModel>((json) => TransaccionModel.fromMap(json))
        .toList();
  }

  // Obtener una transacción por ID
  Future<TransaccionModel?> getTransaccionById(int id) async {
    final response =
        await supabase.from('transacciones').select().eq('id', id).single();

    return response != null ? TransaccionModel.fromMap(response) : null;
  }

  // Crear una transacción
  Future<void> createTransaccion(TransaccionModel transaccion) async {
    await supabase.from('transacciones').insert(transaccion.toMap());
  }

  // Actualizar una transacción
  Future<void> updateTransaccion(String id, Map<String, dynamic> updates) async {
    await supabase.from('transacciones').update(updates).eq('id', id);
  }

  // Eliminar una transacción
  Future<void> deleteTransaccion(String id) async {
    await supabase.from('transacciones').delete().eq('id', id);
  }

  //Joel

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

  // Método para convertir el peso dependiendo de la unidad seleccionada
  double convertWeight(double weight, String weightUnit) {
    switch (weightUnit) {
      case 'kg':
        return weight * 1000; // Convierte kg a gramos
      case 'oz':
        return weight * 31.1035; // Convierte onzas a gramos
      case 'lb':
        return weight * 453.592; // Convierte libras a gramos
      default:
        return weight; // Asume gramos si no es ninguna de las anteriores
    }
  }

  // Método para calcular el precio del oro
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
        purityValue = double.parse(purity.replaceAll('K', ''));
        break;
    }
    double weightInGrams = convertWeight(weight, weightUnit);
    return ((weightInGrams * (goldPrice * purityValue / 1000)) - 5) * 0.94;
  }
}