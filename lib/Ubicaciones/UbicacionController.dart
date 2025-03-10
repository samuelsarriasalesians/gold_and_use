import 'package:supabase_flutter/supabase_flutter.dart';
import 'UbicacionModel.dart';

class UbicacionController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Obtener todas las transacciones
  Future<List<UbicacionModel>> getUbicacion() async {
    final response = await supabase.from('ubicaciones').select();
    
    return response.map<UbicacionModel>((json) => UbicacionModel.fromMap(json)).toList();
  }

  // Obtener una transacción por ID
  Future<UbicacionModel?> getUbicacionById(int id) async {
    final response = await supabase.from('ubicaciones').select().eq('id', id).single();
    
    return response != null ? UbicacionModel.fromMap(response) : null;
  }

  // Crear una transacción
  Future<void> createUbicacion(UbicacionModel ubicacion) async {
    await supabase.from('ubicaciones').insert(ubicacion.toMap());
  }

  // Actualizar una transacción
  Future<void> updateUbicacion(int id, Map<String, dynamic> updates) async {
    await supabase.from('ubicaciones').update(updates).eq('id', id);
  }

  // Eliminar una transacción
  Future<void> deleteUbicacion(int id) async {
    await supabase.from('ubicaciones').delete().eq('id', id);
  }
}
