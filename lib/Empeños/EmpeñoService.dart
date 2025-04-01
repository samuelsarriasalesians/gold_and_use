import 'package:supabase_flutter/supabase_flutter.dart';
import 'EmpenyoModel.dart';

class EmpenyoController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Obtener todos los empeños
  Future<List<EmpenyoModel>> getEmpenyos() async {
    final response = await supabase.from('empeños').select();
    
    return response.map<EmpenyoModel>((json) => EmpenyoModel.fromMap(json)).toList();
  }

  // Obtener un empeño por ID
  Future<EmpenyoModel?> getEmpenyoById(int id) async {
    final response = await supabase.from('empeños').select().eq('id', id).single();
    
    return response != null ? EmpenyoModel.fromMap(response) : null;
  }

  // Crear un empeño
  Future<void> createEmpenyo(EmpenyoModel empenyo) async {
    await supabase.from('empeños').insert(empenyo.toMap());
  }

  // Actualizar un empeño
  Future<void> updateEmpenyo(int id, Map<String, dynamic> updates) async {
    await supabase.from('empeños').update(updates).eq('id', id);
  }

  // Eliminar un empeño
  Future<void> deleteEmpenyo(int id) async {
    await supabase.from('empeños').delete().eq('id', id);
  }
}
