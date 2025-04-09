// InversionValidationService.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'InversionModel.dart';

class InversionValidationService {
  static final _supabase = Supabase.instance.client;

  static Future<bool> validarSaldoDisponible(String userId, double monto) async {
    try {
      final user = await _supabase
          .from('users')
          .select('cantidad_total')
          .eq('id', userId)
          .maybeSingle();
      if (user == null) return false;
      final saldo = double.tryParse(user['cantidad_total'].toString()) ?? 0;
      return saldo >= monto;
    } catch (e) {
      print("Error al validar saldo: $e");
      return false;
    }
  }

  static Future<bool> confirmarOperacion(String mensaje) async {
    // Este método es simbólico, la implementación real de la UI se hace en el screen
    return true;
  }
}
