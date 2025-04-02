import 'package:supabase_flutter/supabase_flutter.dart';

class QrService {
  static Future<Map<String, dynamic>> procesarTransaccion(
    String userId,
    String tipo,
    double monto,
  ) async {
    final supabase = Supabase.instance.client;
    try {
      final userData = await supabase
          .from('users')
          .select('cantidad_total')
          .eq('id', userId)
          .maybeSingle();

      if (userData == null) {
        return {'success': false, 'message': 'Usuario no encontrado'};
      }

      double saldoActual = double.tryParse(userData['cantidad_total'].toString()) ?? 0;

      if (tipo == 'compra') {
        if (saldoActual < monto) {
          return {'success': false, 'message': 'Saldo insuficiente para la compra'};
        }
        saldoActual -= monto;
      } else if (tipo == 'venta') {
        saldoActual += monto;
      } else {
        return {'success': false, 'message': 'Tipo de transacción inválido'};
      }

      await supabase.from('users').update({'cantidad_total': saldoActual}).eq('id', userId);

      await supabase.from('transacciones').insert({
        'usuario_id': userId,
        'tipo': tipo,
        'total': monto,
        'fecha': DateTime.now().toIso8601String(),
      });

      return {'success': true, 'message': 'Transacción procesada con éxito'};
    } catch (e) {
      print("Error procesando transacción: $e");
      return {'success': false, 'message': 'Error inesperado'};
    }
  }
} 