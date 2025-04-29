import 'package:supabase_flutter/supabase_flutter.dart';

class HomeService {
  static Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('isAdmin, cantidad_total')
          .eq('auth_user_id', userId) // 👈 CAMBIA ESTO
          .single();

      if (response == null) {
        print("No se encontró el usuario con auth_user_id: $userId");
        return {
          'isAdmin': false,
          'userSalary': "Error: Usuario no encontrado",
        };
      }

      return {
        'isAdmin': response['isAdmin'] ?? false,
        'userSalary': response['cantidad_total']?.toString() ?? "No disponible",
      };
    } catch (e) {
      print("Error obteniendo datos del usuario: $e");
      return {
        'isAdmin': false,
        'userSalary': "Error al cargar sueldo",
      };
    }
  }
}
