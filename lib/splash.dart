import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Usamos Future.delayed para esperar 3 segundos antes de navegar
    Future.delayed(const Duration(seconds: 3), () {
      // Navegar a la pantalla principal
      Navigator.of(context).pushReplacementNamed('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fondo con color claro
      body: Center(
        // Ajusta el tamaño del GIF según tus necesidades
        child: Image.asset(
          'assets/splash.gif', 
          width: MediaQuery.of(context).size.width, // Establece el ancho al 100% de la pantalla
          height: MediaQuery.of(context).size.height, // Establece el alto al 100% de la pantalla
        ),
      ),
    );
  }
}
