import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'InversionModel.dart';

class InversionService {
  static final _supabase = Supabase.instance.client;
  final Dio _dio = Dio();

  Future<double?> getGoldPriceEuroPerGram() async {
    try {
      final response = await _dio.get(
        'https://api.metalpriceapi.com/v1/latest?api_key=2322844cf20475d079b0145ad8456b0c&base=EUR&currencies=XAU',
      );
      final xau = response.data['rates']['XAU'];
      if (xau != null && xau > 0) {
        final eurPerOunce = 1 / xau;
        return eurPerOunce / 31.1035;
      }
    } catch (e) {
      print('Error al obtener precio del oro: \$e');
    }
    return null;
  }

  static Future<List<InversionModel>> getInversionesByUser(
      String userId) async {
    try {
      final response = await _supabase
          .from('inversiones')
          .select()
          .eq('usuario_id', userId)
          .order('fecha_inicio', ascending: false);

      return (response as List)
          .map((item) => InversionModel.fromMap(item))
          .toList();
    } catch (e) {
      print("Error al cargar inversiones: \$e");
      return [];
    }
  }

  static Future<bool> agregarInversion(InversionModel inversion) async {
    try {
      final user = await _supabase
          .from('users')
          .select('cantidad_total')
          .eq('id', inversion.usuarioId)
          .maybeSingle();

      if (user == null) return false;
      final saldo = double.tryParse(user['cantidad_total'].toString()) ?? 0;

      if (saldo < inversion.cantidad) return false;

      await _supabase.from('users').update({
        'cantidad_total': saldo - inversion.cantidad,
      }).eq('id', inversion.usuarioId);

      await _supabase.from('inversiones').insert(inversion.toMap());
      return true;
    } catch (e) {
      print("Error al agregar inversión: \$e");
      return false;
    }
  }

  static Future<bool> cerrarInversion(InversionModel inversion) async {
    try {
      final ganancia = inversion.cantidad * (1 + inversion.rendimiento / 100);

      await _supabase.from('inversiones').update({
        'estado': 'completada',
        'fecha_fin': DateTime.now().toIso8601String(),
      }).eq('id', inversion.id);

      final user = await _supabase
          .from('users')
          .select('cantidad_total')
          .eq('id', inversion.usuarioId)
          .maybeSingle();

      if (user == null) return false;
      final saldo = double.tryParse(user['cantidad_total'].toString()) ?? 0;

      await _supabase.from('users').update({
        'cantidad_total': saldo + ganancia,
      }).eq('id', inversion.usuarioId);

      return true;
    } catch (e) {
      print("Error al cerrar inversión: \$e");
      return false;
    }
  }

  static Future<void> actualizarRendimientosSemanales() async {
    try {
      final response =
          await _supabase.from('inversiones').select().eq('estado', 'activa');

      for (final map in response as List) {
        final inversion = InversionModel.fromMap(map);
        final semanas =
            DateTime.now().difference(inversion.fechaInicio).inDays ~/ 7;
        final nuevoRendimiento = semanas * 1.5;

        await _supabase
            .from('inversiones')
            .update({'rendimiento': nuevoRendimiento}).eq('id', inversion.id);
      }
    } catch (e) {
      print("Error actualizando rendimientos: \$e");
    }
  }

  Future<double?> calcularGananciaPorcentualDesdeOro(
    double inversionCantidad,
    DateTime fechaInicio,
  ) async {
    try {
      // Precio actual del oro en €/g
      final precioActual = await getGoldPriceEuroPerGram();
      if (precioActual == null) return null;

      // Simulamos un precio de compra según la antigüedad
      final dias = DateTime.now().difference(fechaInicio).inDays;
      final factor = 1 - (dias * 0.0007); // depreciación simulada diaria
      final precioCompra =
          precioActual * (factor > 0.7 ? factor : 0.7); // límite mínimo

      final ganancia = ((precioActual - precioCompra) / precioCompra) * 100;
      return ganancia;
    } catch (e) {
      print('Error en cálculo de ganancia desde oro: $e');
      return null;
    }
  }

  static Future<int> contarInversionesLargas(String userId,
      {int semanas = 4}) async {
    try {
      final response = await _supabase
          .from('inversiones')
          .select()
          .eq('usuario_id', userId)
          .eq('estado', 'activa');

      final now = DateTime.now();
      int contador = 0;

      for (final map in response as List) {
        final inversion = InversionModel.fromMap(map);
        final diff = now.difference(inversion.fechaInicio).inDays;
        if (diff >= semanas * 7) contador++;
      }

      return contador;
    } catch (e) {
      print("Error al contar inversiones largas: \$e");
      return 0;
    }
  }
}
