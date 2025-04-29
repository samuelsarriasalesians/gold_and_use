import 'package:flutter/material.dart';
import 'UbicacionModel.dart';
import 'UbicacioneService.dart';


class UbicacionScreen extends StatefulWidget {
  const UbicacionScreen({super.key});

  @override
  _UbicacionScreenState createState() => _UbicacionScreenState();
}

class _UbicacionScreenState extends State<UbicacionScreen> {
  final UbicacionController ubicacionController = UbicacionController();
  late Future<List<UbicacionModel>> futureUbicaciones;

  @override
  void initState() {
    super.initState();
    futureUbicaciones = ubicacionController.getUbicacion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubicaciones')),
      body: FutureBuilder<List<UbicacionModel>>(
        future: futureUbicaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay ubicaciones registradas'));
          }

          final ubicaciones = snapshot.data!;

          return ListView.builder(
            itemCount: ubicaciones.length,
            itemBuilder: (context, index) {
              final ubicacion = ubicaciones[index];

              return Card(
                child: ListTile(
                  title: Text(ubicacion.nombre),
                  subtitle: Text('Dirección: ${ubicacion.direccion}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
