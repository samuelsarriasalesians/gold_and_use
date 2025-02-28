import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia un temporizador de 2.5 segundos
    Timer(Duration(seconds: 3), () {
      // Navega a la pantalla de inicio de sesión
      Navigator.of(context).pushReplacementNamed('/'); // Cambia esto si la ruta de inicio es diferente
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Set background color
      body: Center(
        child: Image.asset('assets/splash.gif'), // Asegúrate de que la ruta sea correcta
      ),
    );
  }
}