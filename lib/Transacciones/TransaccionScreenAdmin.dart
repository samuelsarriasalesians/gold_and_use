import 'package:flutter/material.dart';
import 'TransaccioneService.dart';
import 'TransaccionModel.dart';

class AdminTransaccionesScreen extends StatefulWidget {
  const AdminTransaccionesScreen({super.key});

  @override
  _AdminTransaccionesScreenState createState() => _AdminTransaccionesScreenState();
}

class _AdminTransaccionesScreenState extends State<AdminTransaccionesScreen> {
  List<TransaccionModel> _transacciones = [];
  List<TransaccionModel> _filteredTransacciones = [];
  String _selectedTipo = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadTransacciones();
  }

  // Cargar las transacciones
  Future<void> _loadTransacciones() async {
    final transacciones = await TransaccionController().getTransacciones();
    setState(() {
      _transacciones = transacciones;
      _filteredTransacciones = _transacciones;
    });
  }

  // Filtrar transacciones por tipo (compra o venta)
  void _filterByTipo(String tipo) {
    setState(() {
      _selectedTipo = tipo;
      if (tipo == 'Todos') {
        _filteredTransacciones = _transacciones;
      } else {
        _filteredTransacciones = _transacciones
            .where((transaccion) => transaccion.tipo == tipo)
            .toList();
      }
    });
  }

  // Eliminar una transacción
  Future<void> _eliminarTransaccion(String id) async {
    try {
      await TransaccionController().deleteTransaccion(id);
      setState(() {
        _transacciones.removeWhere((transaccion) => transaccion.id == id);
        _filteredTransacciones.removeWhere((transaccion) => transaccion.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transacción eliminada")));
    } catch (e) {
      print("Error al eliminar transacción: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al eliminar transacción")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Transacciones"),
        backgroundColor: Colors.amber,
        actions: [
          PopupMenuButton<String>(
            onSelected: _filterByTipo,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Todos', child: Text('Todos')),
              const PopupMenuItem(value: 'compra', child: Text('Compra')),
              const PopupMenuItem(value: 'venta', child: Text('Venta')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_filteredTransacciones.isEmpty)
              const Center(child: Text("No hay transacciones para mostrar")),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTransacciones.length,
                itemBuilder: (context, index) {
                  final transaccion = _filteredTransacciones[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        'Transacción: ${transaccion.tipo} - \$${transaccion.total}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Fecha: ${transaccion.fecha}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarTransaccion(transaccion.id),
                      ),
                      onTap: () {
                        // Puedes agregar más funcionalidad para editar la transacción aquí.
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
