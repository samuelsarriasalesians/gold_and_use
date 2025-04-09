import 'package:supabase_flutter/supabase_flutter.dart';
import '../Consultas/ConsultorModel.dart';

class ConsultorService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Obtener todas las consultas del usuario actual
  Future<List<ConsultorModel>> getConsultasByUser(String userId) async {
    final response = await supabase
        .from('consultor')
        .select('*')
        .eq('usuario_id', userId)
        .order('fecha_creacion', ascending: false); // Más recientes primero

    return (response as List)
        .map((consulta) => ConsultorModel.fromJson(consulta))
        .toList();
  }
}
