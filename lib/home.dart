import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Transacciones/GoldPriceChart.dart';
import 'services/HomeService.dart';

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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final result = await HomeService.getUserData(userId);
    setState(() {
      isAdmin = result["isAdmin"];
      userSalary = result["userSalary"];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final buttonSize = isSmallScreen ? 130.0 : 160.0;
    final iconSize = isSmallScreen ? 60.0 : 80.0;
    final fontSize = isSmallScreen ? 14.0 : 18.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildMenu(buttonSize, iconSize, fontSize),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            const GoldPriceChart(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      backgroundColor: const Color(0xFFFFD700),
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sueldo: \$${userSalary}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Expanded(
                child: Center(
                  child: Image.asset('assets/logo.png', height: 45),
                ),
              ),
              _buildSettingsMenu(),
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
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
        if (isAdmin) const PopupMenuItem(value: 'admin', child: Text('Admin')),
        const PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
    );
  }

  Widget _buildMenu(double buttonSize, double iconSize, double fontSize) {
    final items = [
      {'route': '/transacciones_screen', 'icon': 'assets/transacciones.png', 'label': 'Transacciones'},
      {'route': '/maps', 'icon': 'assets/Ubicaciones/maps.png', 'label': 'Ubicaciones'},
      {'route': '/inversiones_screen', 'icon': 'assets/Inversiones/icono.png', 'label': 'Inversiones'},
      {'route': '/empeños', 'icon': 'assets/Empeños/icono.png', 'label': 'Empeños'},
      {'route': '/qr_screen', 'icon': 'assets/qr_icon.png', 'label': 'QR'},      
    ];

    List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 2) {
      if (i + 1 < items.length) {
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton(items[i], buttonSize, iconSize, fontSize),
            const SizedBox(width: 12),
            _buildMenuButton(items[i + 1], buttonSize, iconSize, fontSize),
          ],
        ));
      } else {
        rows.add(Center(child: _buildMenuButton(items[i], buttonSize, iconSize, fontSize)));
      }
      rows.add(const SizedBox(height: 16));
    }

    return Column(children: rows);
  }

  Widget _buildMenuButton(Map<String, String> item, double size, double iconSize, double fontSize) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(item['route']!),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(item['icon']!, height: iconSize, width: iconSize),
            const SizedBox(height: 10),
            Text(
              item['label']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFD700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}