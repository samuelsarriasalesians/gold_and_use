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
      final data = inversion.toMap();
      await _supabase.from('inversiones').insert(data);
      return true;
    } catch (e) {
      print("Error al agregar inversión: $e");
      return false;
    }
  }

  static Future<bool> cerrarInversion(int id, DateTime fechaFin) async {
    try {
      await _supabase.from('inversiones').update({
        'estado': 'finalizada',
        'fecha_fin': fechaFin.toIso8601String(),
      }).eq('id', id);
      return true;
    } catch (e) {
      print("Error al cerrar inversión: $e");
      return false;
    }
  }
}
