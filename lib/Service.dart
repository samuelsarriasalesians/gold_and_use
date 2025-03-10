import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Registro de usuario
  Future<AuthResponse?> signUp(String email, String password, String nombre) async {
    try {
      final res = await supabase.auth.signUp(email: email, password: password);
      final user = res.user;

      if (user != null) {
        await supabase.from('users').insert({
          'id': user.id,
          'nombre': nombre,
          'email': email,
          'fecha_creacion': DateTime.now().toIso8601String(),
        });
      }
      return res;
    } catch (e) {
      print('Error en signUp: $e');
      return null;
    }
  }

  // Inicio de sesión con email y contraseña
  Future<AuthResponse?> signIn(String email, String password) async {
    try {
      final res = await supabase.auth.signInWithPassword(email: email, password: password);
      return res;
    } catch (e) {
      print('Error en signIn: $e');
      return null;
    }
  }

  // Inicio de sesión con Google
  Future<bool> signInWithGoogle() async {
    try {
      final res = await supabase.auth.signInWithOAuth(OAuthProvider.google);
      return res != null;
    } catch (e) {
      print('Error en signInWithGoogle: $e');
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Obtener usuario actual
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}

class SupabaseService {
  // Obtener el icono según la tabla
  String getIconPath(String tableName) {
    return 'assets/$tableName/icono.png';
  }

  // Función para abrir una pantalla con animación de deslizamiento
  void navigateWithAnimation(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Empieza fuera de la pantalla (derecha)
          const end = Offset.zero; // Termina en su posición normal
          const curve = Curves.easeInOut; // Suaviza la animación

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}
