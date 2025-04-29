import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'InversionModel.dart';

class InversionService {
  static final _supabase = Supabase.instance.client;

  static Future<List<InversionModel>> getInversionesByUser(String userId) async {
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
      print("Error al cargar inversiones: $e");
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
      print("Error al agregar inversión: $e");
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
      print("Error al cerrar inversión: $e");
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
      print("Error actualizando rendimientos: $e");
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
      print("Error al contar inversiones largas: $e");
      return 0;
    }
  }

  /// ✅ Nueva función para calcular % de variación del oro desde fecha de inversión
  static Future<double?> calcularGananciaPorcentualDesdeOro(DateTime fechaInicio) async {
    try {
      final String raw = await rootBundle.loadString('assets/gold_price_data.json');
      final List data = json.decode(raw);

      final precioInicio = _buscarPrecioPorFecha(data, fechaInicio);
      final precioActual = _buscarPrecioPorFecha(data, DateTime.now());

      if (precioInicio == null || precioActual == null) return null;

      final ganancia = ((precioActual - precioInicio) / precioInicio) * 100;
      return double.parse(ganancia.toStringAsFixed(2));
    } catch (e) {
      print("Error al calcular ganancia oro: $e");
      return null;
    }
  }

  static double? _buscarPrecioPorFecha(List data, DateTime fecha) {
    final fechaStr = fecha.toIso8601String().split('T')[0];

    for (final item in data) {
      if (item['date'] == fechaStr) {
        return (item['price'] as num).toDouble();
      }
    }

    for (final item in data.reversed) {
      if (item['date'].compareTo(fechaStr) <= 0) {
        return (item['price'] as num).toDouble();
      }
    }

    return null;
  }
}
