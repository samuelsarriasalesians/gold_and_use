import 'package:flutter/material.dart';
import 'TransaccionController.dart';
import 'TransaccionModel.dart';

class TransaccionScreen extends StatefulWidget {
  @override
  _TransaccionScreenState createState() => _TransaccionScreenState();
}

class _TransaccionScreenState extends State<TransaccionScreen> {
  final TransaccionController transaccionController = TransaccionController();
  late Future<List<TransaccionModel>> futureTransacciones;

  @override
  void initState() {
    super.initState();
    futureTransacciones = transaccionController.getTransacciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transacciones')),
      body: FutureBuilder<List<TransaccionModel>>(
        future: futureTransacciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay transacciones registradas'));
          }

          final transacciones = snapshot.data!;

          return ListView.builder(
            itemCount: transacciones.length,
            itemBuilder: (context, index) {
              final transaccion = transacciones[index];

              return Card(
                child: ListTile(
                  title: Text('${transaccion.tipo} - ${transaccion.cantidad} gr'),
                  subtitle: Text('Precio Total: ${transaccion.total}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showTransaccionForm(transaccion),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTransaccion(transaccion.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransaccionForm(null),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showTransaccionForm(TransaccionModel? transaccion) {
    final _tipoController = TextEditingController(text: transaccion?.tipo ?? '');
    final _cantidadController = TextEditingController(text: transaccion?.cantidad.toString() ?? '');
    final _precioGramoController = TextEditingController(text: transaccion?.precioGramo.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(transaccion == null ? 'Añadir Transacción' : 'Editar Transacción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tipoController,
                decoration: InputDecoration(labelText: 'Tipo (compra/venta)'),
              ),
              TextField(
                controller: _cantidadController,
                decoration: InputDecoration(labelText: 'Cantidad (gramos)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _precioGramoController,
                decoration: InputDecoration(labelText: 'Precio por gramo'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(transaccion == null ? 'Guardar' : 'Actualizar'),
              onPressed: () async {
                // Aquí agregamos los valores requeridos:
                String usuarioId = "id_del_usuario"; // Obtén el ID del usuario logueado
                DateTime fecha = DateTime.now(); // Fecha de la transacción

                if (transaccion == null) {
                  // Crear una nueva transacción
                  await transaccionController.createTransaccion(TransaccionModel(
                    id: 0, // El ID se generará automáticamente
                    tipo: _tipoController.text,
                    cantidad: double.parse(_cantidadController.text),
                    precioGramo: double.parse(_precioGramoController.text),
                    total: double.parse(_cantidadController.text) * double.parse(_precioGramoController.text),
                    qrCode: '', // Puedes agregar la lógica para el código QR
                    usuarioId: usuarioId, // Añadir el ID del usuario
                    fecha: fecha, // Añadir la fecha de la transacción
                  ));
                } else {
                  // Actualizar una transacción existente
                  await transaccionController.updateTransaccion(transaccion.id, {
                    'tipo': _tipoController.text,
                    'cantidad': double.parse(_cantidadController.text),
                    'precio_gramo': double.parse(_precioGramoController.text),
                  });
                }

                setState(() {
                  futureTransacciones = transaccionController.getTransacciones();
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTransaccion(int id) async {
    await transaccionController.deleteTransaccion(id);
    setState(() {
      futureTransacciones = transaccionController.getTransacciones();
    });
  }
}
