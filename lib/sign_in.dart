import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

import 'constants.dart';

class SignUp extends StatelessWidget {
  final SupabaseClient client = Supabase.instance.client;

  SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Función para navegar después de completar el registro
    void navigateHome(AuthResponse response) async {
      final user = response.user;
      if (user != null) {
        final responseInsert = await client.from('users').insert({
          'nombre': nameController.text,
          'email': emailController.text,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'id': user.id,
        });

        if (responseInsert.error != null) {
          print('Error inserting user: ${responseInsert.error!.message}');
        } else {
          print('User inserted successfully');
        }
      }
      Navigator.of(context).pushReplacementNamed('/home');
    }

    // Tema personalizado para modo oscuro con bordes finos negros en los campos de texto
    final darkModeThemeData = ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color.fromARGB(248, 183, 183, 183),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFFF5F5F5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1.0), // Borde negro fino
        ),
        labelStyle: const TextStyle(color: Colors.black), // Texto de la etiqueta en negro
        hintStyle: const TextStyle(color: Colors.black), // Texto en negro
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black), // Texto en negro
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Colors.black, width: 1.0), // Borde negro para checkboxes
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Logo en la parte superior
          Center(
            child: Image.asset(
              'assets/logo.png',
              height: 50,
            ),
          ),
          const SizedBox(height: 24),
          // Formulario de registro con email y contraseña (tema oscuro)
          Card(
            elevation: 10,
            color: const Color.fromARGB(255, 255, 255, 255),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Theme(
                data: darkModeThemeData, // Aplicamos el tema oscuro
                child: Column(
                  children: [
                    // Campo de Username personalizado
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black, width: 1.0),
                        ),
                      ),
                      textAlign: TextAlign.left, // Alineación a la izquierda
                    ),
                    const SizedBox(height: 16),
                    SupaEmailAuth(
                      redirectTo: kIsWeb ? null : 'io.supabase.flutter://',
                      onSignInComplete: navigateHome,
                      onSignUpComplete: navigateHome,
                      prefixIconEmail: null,
                      prefixIconPassword: null,
                      localization: const SupaEmailAuthLocalization(
                        enterEmail: "Email",
                        enterPassword: "Password",
                        dontHaveAccount: "Sign up",
                        forgotPassword: "Forgot password",
                      ),
                      metadataFields: [
                        BooleanMetaDataField(
                          label: 'Keep me up to date with the latest news and updates.',
                          key: 'marketing_consent',
                          checkboxPosition: ListTileControlAffinity.leading,
                        ),
                        BooleanMetaDataField(
                          key: 'terms_agreement',
                          isRequired: true,
                          checkboxPosition: ListTileControlAffinity.leading,
                          richLabelSpans: [
                            const TextSpan(text: 'I have read and agree to the '),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: const TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print('Terms and Conditions tapped');
                                },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          // Espaciador
          const SizedBox(height: 16),
          // Opción de autenticación con redes sociales
          SupaSocialsAuth(
            colored: true,
            nativeGoogleAuthConfig: const NativeGoogleAuthConfig(
              webClientId:
                  '126321708933-i6cako6j9bs73g05er07rp5te4o70dkt.apps.googleusercontent.com',
              iosClientId:
                  'TU_IOS_CLIENT_ID_AQUI', // Este lo tendrás que obtener o configurar en la consola de Google
            ),
            enableNativeAppleAuth: true,
            socialProviders: [
              OAuthProvider.google,
            ],
            onSuccess: (session) {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
        ],
      ),
    );
  }
}