import 'package:supabase_flutter/supabase_flutter.dart';
import '../Users/UserModel.dart';

class UserService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> syncOrCreateUser({
    required String nombre,
    required String email,
    required String authUserId,
    String? photoUrl,
  }) async {
    final result = await supabase
        .from('users')
        .select()
        .eq('email', email)
        .limit(1); // 🔄 Solo selecciona 1 para evitar el error 406

    if (result.isNotEmpty) {
      final existing = result.first;
      // Si ya existe un usuario con ese email pero no está vinculado al auth
      if (existing['auth_user_id'] == null) {
        await supabase
            .from('users')
            .update({'auth_user_id': authUserId}).eq('id', existing['id']);
      }
    } else {
      await supabase.from('users').insert({
        'nombre': nombre,
        'email': email,
        'auth_user_id': authUserId,
        'cantidad_total': 0, // ✅ requerido por la tabla
        'photo_url': photoUrl,
        'isAdmin': false,
      });
    }
  }

  // Crear usuario si no existe por email
  Future<void> createUserIfNotExists(UserModel user) async {
    final result = await supabase
        .from('users')
        .select('id')
        .eq('email', user.email)
        .limit(1); // ✅ evitar .maybeSingle()

    if (result.isEmpty) {
      final userMap = user.toJson();
      userMap['cantidad_total'] = 0; // ✅ por si acaso
      await supabase.from('users').insert(userMap);
    }
  }

  // Ya existente
  Future<List<UserModel>> getUsers() async {
    final response = await supabase.from('users').select();
    return response.map<UserModel>((json) => UserModel.fromJson(json)).toList();
  }

  Future<UserModel?> getUserById(String id) async {
    final response =
        await supabase.from('users').select().eq('id', id).maybeSingle();
    return response != null ? UserModel.fromJson(response) : null;
  }

  Future<void> createUser(UserModel user) async {
    final data = user.toJson();
    data['cantidad_total'] = 0; // por si viene sin este campo
    await supabase.from('users').insert(data);
  }

  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    await supabase.from('users').update(updates).eq('id', id);
  }

  Future<void> deleteUser(String id) async {
    await supabase.from('users').delete().eq('id', id);
  }
}
