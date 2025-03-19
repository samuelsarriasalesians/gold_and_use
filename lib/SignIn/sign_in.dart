import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  bool isLogin = true; // Alterna entre login y registro

  void _handleAuth() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (isLogin) {
      final res = await authService.signIn(email, password);
      if (res?.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showError('Error al iniciar sesión');
      }
    } else {
      String nombre = nombreController.text.trim();
      final res = await authService.signUp(email, password, nombre);
      if (res?.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showError('Error al registrarse');
      }
    }
  }

  void _handleGoogleLogin() async {
    final res = await authService.signInWithGoogle();
    if (res) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showError('Error al iniciar sesión con Google');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final darkModeThemeData = ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color.fromARGB(248, 183, 183, 183),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1.0),
        ),
        labelStyle: const TextStyle(color: Colors.black),
        hintStyle: const TextStyle(color: Colors.black),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Center(
            child: Image.asset(
              'assets/logo.png',
              height: 50,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 10,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Theme(
                data: darkModeThemeData,
                child: Column(
                  children: [
                    if (!isLogin)
                      TextField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1.0),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                        ),
                      ),
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    // Casilla de verificación para admin
                    ElevatedButton(
                      onPressed: _handleAuth,
                      child: Text(isLogin ? 'Iniciar Sesión' : 'Registrarse'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(isLogin
                          ? '¿No tienes cuenta? Regístrate'
                          : '¿Ya tienes cuenta? Inicia sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          SupaSocialsAuth(
            colored: true,
            nativeGoogleAuthConfig: const NativeGoogleAuthConfig(
              webClientId:
                  '126321708933-i6cako6j9bs73g05er07rp5te4o70dkt.apps.googleusercontent.com',
              iosClientId: 'TU_IOS_CLIENT_ID_AQUI',
            ),
            enableNativeAppleAuth: true,
            socialProviders: [
              OAuthProvider.google,
            ],
            onSuccess: (session) {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _handleGoogleLogin,
            child: const Text('Iniciar sesión con Google'),
          ),
        ],
      ),
    );
  }
}
