// ✅ ConsultorService.dart con lógica real y API

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../Consultas/ConsultorModel.dart';
import 'dart:io';


class ConsultorService {
  final SupabaseClient supabase = Supabase.instance.client;
  final Dio _dio = Dio();

  Future<double?> getGoldPriceEuroPerGram() async {
    try {
      final response = await _dio.get(
        'https://api.metalpriceapi.com/v1/latest',
        queryParameters: {
          'api_key': '2322844cf20475d079b0145ad8456b0c',
          'base': 'EUR',
          'currencies': 'XAU',
        },
      );
      final xau = response.data['rates']['XAU'];
      if (xau != null && xau > 0) {
        final eurPerOunce = 1 / xau;
        return eurPerOunce / 31.1035;
      }
    } catch (e) {
      print('Error obteniendo precio del oro: $e');
    }
    return null;
  }



Future<double?> getPrecioOroGramo() async {
  try {
    final response = await _dio.get(
      'https://api.metalpriceapi.com/v1/latest?api_key=2322844cf20475d079b0145ad8456b0c&base=EUR&currencies=XAU',
    );
    final xau = response.data['rates']['XAU'];
    if (xau != null && xau > 0) {
      final eurPerOunce = 1 / xau;
      return eurPerOunce / 31.1035; // convierte a €/g
    }
  } catch (e) {
    print('Error API oro: $e');
  }
  return null;
}


  Future<List<ConsultorModel>> getConsultasUsuario(String userId) async {
    try {
      final data = await supabase
          .from('consultor')
          .select()
          .eq('usuario_id', userId)
          .order('fecha_creacion', ascending: false);

      return (data as List)
          .map((item) => ConsultorModel.fromMap(item))
          .toList();
    } catch (e) {
      print('Error cargando consultas: $e');
      return [];
    }
  }

  Future<bool> enviarConsulta({
    required String userId,
    required String nombre,
    required double peso,
    required double valor,
    required File imagen,
    String? mensaje,
  }) async {
    try {
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storage = Supabase.instance.client.storage;
      final bucket = storage.from('consultoriaimage');

      await bucket.upload(fileName, imagen);
      final imageUrl = bucket.getPublicUrl(fileName);

      final model = {
        'usuario_id': userId,
        'nombre': nombre,
        'peso': peso,
        'valor': valor,
        'imagen_url': imageUrl,
        'mensaje': mensaje,
        'fecha_creacion': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('consultor').insert(model);
      return true;
    } catch (e) {
      print('Error al enviar consulta: $e');
      return false;
    }
  }
}
