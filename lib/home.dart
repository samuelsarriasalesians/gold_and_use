import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Transacciones/TransaccionesGrafico.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAdmin = false;
  String userSalary = "Cargando...";
  final String userId = Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('isAdmin, cantidad_total')
          .eq('id', userId)
          .single();

      setState(() {
        isAdmin = response['isAdmin'] ?? false;
        userSalary = response['cantidad_total']?.toString() ?? "No disponible";
      });
    } catch (e) {
      setState(() {
        userSalary = "Error al cargar sueldo";
      });
      print("Error obteniendo datos del usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: Color(0xFFFFD700),
        elevation: 0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sueldo: \$${userSalary}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Center(
                  child: Image.asset('assets/logo.png', height: 50),
                ),
              ),
              _buildSettingsMenu(),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              buildMenuGrid([
                {
                  'route': '/transacciones_screen',
                  'icon': 'assets/transacciones.png',
                  'label': 'Transacciones'
                },
                {
                  'route': '/maps', 
                  'icon': 'assets/Ubicaciones/icono.png', 
                  'label': 'Ubicaciones'},
                {
                  'route': '/inversiones',
                  'icon': 'assets/Inversiones/icono.png',
                  'label': 'Inversiones'
                },
                {
                  'route': '/empeños',
                  'icon': 'assets/Empeños/icono.png',
                  'label': 'Emepños'
                },
                {
                  'route': '/notificaciones',
                  'icon': 'assets/Notificaciones/icono.png',
                  'label': 'Notificaciones'
                },
                
              ]),
              TransaccionesGrafico(userId: userId),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuButton<String> _buildSettingsMenu() {
    return PopupMenuButton<String>(
      icon: Image.asset('assets/icono_ajustes.png'),
      onSelected: (String result) {
        switch (result) {
          case 'settings':
            Navigator.of(context).pushNamed('/settings_screen');
            break;
          case 'admin':
            Navigator.of(context).pushNamed('/admin_home');
            break;
          case 'logout':
            Supabase.instance.client.auth.signOut();
            Navigator.of(context).pushReplacementNamed('/');
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'settings', child: Text('Settings')),
        if (isAdmin)
          const PopupMenuItem<String>(value: 'admin', child: Text('Admin')),
        const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
      ],
    );
  }

  // Función para construir el grid de botones con alineación automática
  Widget buildMenuGrid(List<Map<String, String>> items) {
    List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 2) {
      if (i + 1 < items.length) {
        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuButton(context, items[i]['icon']!, items[i]['label']!,
                  items[i]['route']!),
              const SizedBox(width: 16),
              _buildMenuButton(context, items[i + 1]['icon']!,
                  items[i + 1]['label']!, items[i + 1]['route']!),
            ],
          ),
        );
      } else {
        rows.add(
          Center(
            child: _buildMenuButton(context, items[i]['icon']!,
                items[i]['label']!, items[i]['route']!),
          ),
        );
      }
      rows.add(const SizedBox(height: 20));
    }
    return Column(children: rows);
  }

  // Función para crear cada botón de menú
  Widget _buildMenuButton(
      BuildContext context, String asset, String text, String route) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
