import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ChatService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Enviar un mensaje
  Future<void> sendMessage(String userId, String nombreUsuario, String contenido, {String? imageUrl}) async {
    await supabase.from('mensajes').insert({
      'usuario_id': userId,
      'nombre_usuario': nombreUsuario,
      'contenido': contenido,
      'imagen_url': imageUrl ?? '', // Si no hay imagen, se pone un valor vacío
    });
  }
  

  // Subir la imagen al bucket
  Future<String?> uploadImage(File imageFile, String userId) async {
    try {
      // Carpeta con el ID del usuario
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Subir la imagen al bucket "mensajesimg"
      final response = await supabase.storage
          .from('mensajesimg') // El bucket donde subiremos las imágenes
          .upload(fileName, imageFile);

      // Verificar si la respuesta es exitosa
      if (response != null && response.isNotEmpty) {
        // Obtener la URL pública de la imagen
        final imageUrl = supabase.storage.from('mensajesimg').getPublicUrl(fileName);
        return imageUrl;
      } else {
        print('Error al subir la imagen: respuesta vacía o nula');
        return null;
      }
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

   // Eliminar un mensaje (solo si es el mensaje del usuario actual)
  Future<void> deleteMessage(int messageId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Verificar si el mensaje pertenece al usuario actual antes de eliminarlo
      final response = await supabase
          .from('mensajes')
          .select()
          .eq('id', messageId)
          .eq('usuario_id', user.id)
          .single();

      if (response != null) {
        // Eliminar el mensaje
        await supabase.from('mensajes').delete().eq('id', messageId);
        print('Mensaje eliminado exitosamente.');
      } else {
        print('No puedes eliminar este mensaje.');
      }
    } catch (e) {
      print('Error al eliminar el mensaje: $e');
    }
  }

  // Recibir mensajes en tiempo real
  Stream<List<Map<String, dynamic>>> getMessages() {
    return supabase
      .from('mensajes')
      .stream(primaryKey: ['id'])
      .order('fecha_creacion', ascending: true);
  }

   Future<void> editMessage(String messageId, String newContent) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Verificar si el mensaje pertenece al usuario actual
      final response = await supabase
          .from('mensajes')
          .select()
          .eq('id', messageId)
          .eq('usuario_id', user.id)
          .single();

      if (response != null) {
        // Actualizar el contenido del mensaje
        await supabase.from('mensajes').update({
          'contenido': newContent,
          'fecha_creacion': DateTime.now().toIso8601String(),
        }).eq('id', messageId);

        print('Mensaje actualizado exitosamente.');
      } else {
        print('No puedes editar este mensaje.');
      }
    } catch (e) {
      print('Error al editar el mensaje: $e');
    }
  }
}


