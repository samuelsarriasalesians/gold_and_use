import './phone_sign_up.dart';
import './splash.dart'; // Asegúrate de importar el nuevo archivo
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import './home.dart';
import './sign_in.dart';
import './magic_link.dart';
import './update_password.dart';
import 'phone_sign_in.dart';
import './verify_phone.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// TODO: replace with your credentials
  await Supabase.initialize(
    url: 'https://dsjtherowikanmjmsiiv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRzanRoZXJvd2lrYW5tam1zaWl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk4MTYzNDIsImV4cCI6MjA1NTM5MjM0Mn0.DhF6IzCHkWExDBEfuiTkP61sPGOBDS6ib1tkKU8FE1E',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gold&use',
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: '/splash', // Cambia la ruta inicial al splash
      routes: {
        '/splash': (context) => SplashScreen(), // Ruta para el splash
        '/': (context) => SignUp(), // Ruta para el inicio de sesión/registro
        '/magic_link': (context) => const MagicLink(),
        '/update_password': (context) => const UpdatePassword(),
        '/phone_sign_in': (context) => const PhoneSignIn(),
        '/phone_sign_up': (context) => const PhoneSignUp(),
        '/verify_phone': (context) => const VerifyPhone(),
        '/home': (context) => const Home(),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const Scaffold(
            body: Center(
              child: Text(
                'Not Found',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}