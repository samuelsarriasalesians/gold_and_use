import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Notificación al actualizar perfil
  Future<void> sendProfileUpdateNotification(String field, String? newValue) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      String message = _getUpdateMessage(field, newValue);
      if (message.isNotEmpty) {
        await _createNotification(userId, message);
      }
    } catch (e) {
      print('Error al enviar notificación: $e');
    }
  }

  // Notificación de prueba
  Future<void> sendTestNotification(String message) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _createNotification(userId, message);
    } catch (e) {
      print('Error en notificación de prueba: $e');
    }
  }

  // Nueva: notificación al crear una consulta
  Future<void> sendNewConsultationNotification(String nombreConsulta, String? mensaje) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      String text = 'Tu consulta sobre "$nombreConsulta" ha sido registrada.';
      if (mensaje != null && mensaje.trim().isNotEmpty) {
        text += '\nMensaje incluido: "$mensaje"';
      }

      await _createNotification(userId, text);
    } catch (e) {
      print('Error al notificar nueva consulta: $e');
    }
  }

  // Contador de no leídas
  Future<int> getUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('notificaciones')
          .select()
          .eq('usuario_id', userId)
          .eq('leido', false);

      return response.length;
    } catch (e) {
      print('Error al contar notificaciones: $e');
      return 0;
    }
  }

  // --- Privados ---
  String _getUpdateMessage(String field, String? newValue) {
    switch (field) {
      case 'nombre':
        return 'Se actualizó tu nombre a: $newValue';
      case 'telefono':
        return 'Se actualizó tu teléfono: $newValue';
      case 'direccion':
        return 'Se actualizó tu dirección';
      case 'photo_url':
        return newValue != null
            ? 'Se actualizó tu foto de perfil'
            : 'Se eliminó tu foto de perfil';
      default:
        return '';
    }
  }

  Future<void> _createNotification(String userId, String message) async {
    await _supabase.from('notificaciones').insert({
      'usuario_id': userId,
      'mensaje': message,
      'leido': false,
      'fecha': DateTime.now().toIso8601String(), // ¡Incluye la fecha!
    });
  }
}
