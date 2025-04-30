import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // Importamos provider
import '../Mensajeria/theme_notifier.dart';  // Importa tu ThemeNotifier

import 'AdminHome.dart';
import 'Mensajeria/ChatScreen.dart';
import 'Consultas/ConsultorScreen.dart';
import 'Inversiones/InversionScreen.dart';
import 'QR/QrScanScreen.dart';
import 'SignIn/phone_sign_up.dart';
import 'splash.dart'; // Asegúrate de importar el nuevo archivo
import './home.dart';
import 'SignIn/sign_in.dart';
import 'SignIn/update_password.dart';
import 'SignIn/phone_sign_in.dart';
import 'SignIn/verify_phone.dart';
import './settings_screen.dart';
import './AdminHome.dart';
import 'Transacciones/transactions_screen.dart';
import 'Maps/maps_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase
  await Supabase.initialize(
    url: 'https://dsjtherowikanmjmsiiv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRzanRoZXJvd2lrYW5tam1zaWl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk4MTYzNDIsImV4cCI6MjA1NTM5MjM0Mn0.DhF6IzCHkWExDBEfuiTkP61sPGOBDS6ib1tkKU8FE1E',
  );

  // Run the app with ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(), // Creamos el provider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el estado del tema desde ThemeNotifier
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gold&use',
      themeMode: themeNotifier.value,  // Usamos el ThemeMode que tenga el ThemeNotifier
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFD700),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primarySwatch: Colors.amber,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Color(0xFFFFD700),
          elevation: 0,
        ),
      ),
      initialRoute: '/splash', 
      routes: {
        '/splash': (context) => SplashScreen(), // Ruta para el splash
        '/': (context) =>
            LoginScreen(), // Ruta para el inicio de sesión/registro
        '/update_password': (context) => const UpdatePassword(),
        '/phone_sign_in': (context) => const PhoneSignIn(),
        '/phone_sign_up': (context) => const PhoneSignUp(),
        '/verify_phone': (context) => const VerifyPhone(),
        '/home': (context) => const Home(),
        '/admin_home': (context) => Adminhome(),
        '/settings_screen': (context) =>
            SettingsScreen(), // Ruta para la pantalla de ajustes
        '/transacciones_screen': (context) =>
            TransactionsScreen(), // Ruta para la pantalla de ajustes
        '/maps': (context) => const MapsScreen(),
        '/qr_screen': (context) => QrScanScreen(),
        '/inversiones_screen': (context) => const InversionScreen(),
        '/consultor_screen': (context) => const ConsultorScreen(),
        '/mensajes_screen': (context) => const ChatScreen(),

        
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