import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Users/UserService.dart';
import '../Users/UserModel.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final UserService userService = UserService();

  bool isLogin = true;
  bool loading = false;

  void _handleAuth() async {
    setState(() => loading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final nombre = nombreController.text.trim();

    try {
      if (isLogin) {
        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        await _syncUser(res.user, nombre);
      } else {
        final res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        await _syncUser(res.user, nombre);
      }

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showError("Error de autenticación: ${e.toString()}");
    }

    setState(() => loading = false);
  }

  void _handleGoogleLogin() async {
    setState(() => loading = true);
    try {
      final res = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
      );
      // Navegación automática se hace desde SupaSocialsAuth si lo usas
    } catch (e) {
      _showError("Google Login Error: ${e.toString()}");
    }
    setState(() => loading = false);
  }

  Future<void> _syncUser(User? user, String nombre) async {
    if (user == null) return;

    await userService.syncOrCreateUser(
      nombre: nombre.isNotEmpty ? nombre : (user.userMetadata?['name'] ?? 'Sin nombre'),
      email: user.email ?? '',
      authUserId: user.id,
      photoUrl: user.userMetadata?['avatar_url'],
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                const SizedBox(height: 40),
                Center(child: Image.asset('assets/logo.png', height: 60)),
                const SizedBox(height: 24),
                Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if (!isLogin)
                          TextField(
                            controller: nombreController,
                            decoration: const InputDecoration(labelText: 'Nombre'),
                          ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: passwordController,
                          decoration: const InputDecoration(labelText: 'Contraseña'),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _handleAuth,
                          child: Text(isLogin ? 'Iniciar Sesión' : 'Registrarse'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => isLogin = !isLogin);
                          },
                          child: Text(isLogin
                              ? '¿No tienes cuenta? Regístrate'
                              : '¿Ya tienes cuenta? Inicia sesión'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _handleGoogleLogin,
                  icon: const Icon(Icons.login),
                  label: const Text("Iniciar sesión con Google"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                ),
              ],
            ),
    );
  }
}
