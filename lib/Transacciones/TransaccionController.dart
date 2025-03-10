import 'package:supabase_flutter/supabase_flutter.dart';
import 'TransaccionModel.dart';

class TransaccionController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Obtener todas las transacciones
  Future<List<TransaccionModel>> getTransacciones() async {
    final response = await supabase.from('transacciones').select();
    
    return response.map<TransaccionModel>((json) => TransaccionModel.fromMap(json)).toList();
  }

  // Obtener una transacción por ID
  Future<TransaccionModel?> getTransaccionById(int id) async {
    final response = await supabase.from('transacciones').select().eq('id', id).single();
    
    return response != null ? TransaccionModel.fromMap(response) : null;
  }

  // Crear una transacción
  Future<void> createTransaccion(TransaccionModel transaccion) async {
    await supabase.from('transacciones').insert(transaccion.toMap());
  }

  // Actualizar una transacción
  Future<void> updateTransaccion(int id, Map<String, dynamic> updates) async {
    await supabase.from('transacciones').update(updates).eq('id', id);
  }

  // Eliminar una transacción
  Future<void> deleteTransaccion(int id) async {
    await supabase.from('transacciones').delete().eq('id', id);
  }
}
