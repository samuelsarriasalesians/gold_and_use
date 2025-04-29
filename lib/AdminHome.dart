import 'package:gold_and_use/Transacciones/TransaccionScreenAdmin.dart';
import 'package:flutter/material.dart';
import 'Users/UserScreenAdmin.dart';
import 'Ubicaciones/UbicacionScreenAdmin.dart';
import '../Service.dart';

class Adminhome extends StatelessWidget {
  final SupabaseService service = SupabaseService();

  final List<Map<String, dynamic>> sections = [
    {'title': 'Usuarios', 'folder': 'Users', 'screen': UserScreen()},
    {
      'title': 'Transacciones',
      'folder': 'Transacciones',
      'screen': const AdminTransaccionesScreen()
    },
    {
      'title': 'Inversiones',
      'folder': 'Inversiones',
      'screen': PlaceholderScreen('Inversiones')
    },
    {
      'title': 'Ubicaciones',
      'folder': 'Ubicaciones',
      'screen': UbicacionScreen()
    },
    {
      'title': 'Notificaciones',
      'folder': 'Notificaciones',
      'screen': PlaceholderScreen('Notificaciones')
    },
  ];

  Adminhome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Tablas')),
      body: Padding(
        padding:
            const EdgeInsets.all(10.0), // Menos padding para ahorrar espacio
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Dos columnas
            crossAxisSpacing: 10, // Menos espacio entre columnas
            mainAxisSpacing: 10, // Menos espacio entre filas
            childAspectRatio: 1.0, // Ajustar el tamaño de los cuadrados
          ),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            return _buildGridItem(
              context,
              sections[index]['title'],
              sections[index]['folder'],
              sections[index]['screen'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridItem(
      BuildContext context, String title, String folder, Widget screen) {
    return GestureDetector(
      onTap: () {
        service.navigateWithAnimation(
            context, screen); // Usa la nueva animación
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                service.getIconPath(folder),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Pantalla de $title en construcción')),
    );
  }
}
