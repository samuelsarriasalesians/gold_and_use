import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Enviar un mensaje
  Future<void> sendMessage(String userId, String nombreUsuario, String contenido) async {
    await supabase.from('mensajes').insert({
      'usuario_id': userId,
      'nombre_usuario': nombreUsuario,
      'contenido': contenido,
    });
  }

  // Recibir mensajes en tiempo real
  Stream<List<Map<String, dynamic>>> getMessages() {
  return supabase
    .from('mensajes')
    .stream(primaryKey: ['id'])
    .order('fecha_creacion', ascending: true);
}

}
