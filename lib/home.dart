import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'constants.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Image.asset(
          'assets/logo.png',
          height: 50,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Image.asset('assets/icono_ajustes.png'),
            onSelected: (String result) {
              switch (result) {
                case 'profile':
                  Navigator.of(context).pushNamed('/account_screen');
                  break;
                case 'settings':
                  Navigator.of(context).pushNamed('/admin_home');
                  break;
                case 'logout':
                  Supabase.instance.client.auth.signOut();
                  Navigator.of(context).pushReplacementNamed('/');
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Admin'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Evita el desbordamiento
        child: Padding(
          padding: const EdgeInsets.all(
              16.0), // Agrega margen para mejor visualización
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Botones QR y Transacciones (Se adaptan al ancho de la pantalla)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMenuButton(
                      context,
                      'assets/transacciones.png',
                      'Transacciones',
                      screenWidth,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Botón de Maps (Se adapta al ancho)
              _buildMenuButton(
                context,
                'assets/maps.png',
                'Maps',
                screenWidth *
                    0.8, // Ajustamos el ancho para que no ocupe toda la pantalla
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
  BuildContext context,
  String asset,
  String text,
  double screenWidth, {
  VoidCallback? onTap, // Agregar el parámetro onTap
}) {
  return GestureDetector(
    onTap: onTap,  // Usar el onTap proporcionado
    child: Container(
      width: screenWidth * 0.4,
      constraints: const BoxConstraints(maxWidth: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Image.asset(asset, height: 80, width: 80),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
            ),
          ),
        ],
      ),
    ),
  );
}
}