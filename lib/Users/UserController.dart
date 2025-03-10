import 'package:supabase_flutter/supabase_flutter.dart';

import 'UserModel.dart';

class UserController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Obtener todos los usuarios
  Future<List<UserModel>> getUsers() async {
    final response = await supabase.from('users').select();
    
    return response.map<UserModel>((json) => UserModel.fromJson(json)).toList();
  }

  // Obtener un usuario por ID
  Future<UserModel?> getUserById(String id) async {
    final response = await supabase.from('users').select().eq('id', id).single();
    
    return response != null ? UserModel.fromJson(response) : null;
  }

  // Crear un usuario
  Future<void> createUser(UserModel user) async {
    await supabase.from('users').insert(user.toJson());
  }

  // Actualizar un usuario
  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    await supabase.from('users').update(updates).eq('id', id);
  }

  // Eliminar un usuario
  Future<void> deleteUser(String id) async {
    await supabase.from('users').delete().eq('id', id);
  }
}
