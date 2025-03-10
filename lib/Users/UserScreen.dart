import 'package:flutter/material.dart';
import 'UserController.dart';
import 'UserModel.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserController userController = UserController();
  late Future<List<UserModel>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = userController.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuarios')),
      body: FutureBuilder<List<UserModel>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay usuarios registrados'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Card(
                child: ListTile(
                  title: Text(user.nombre),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showUserForm(user),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user.id),
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
        onPressed: () => _showUserForm(null),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showUserForm(UserModel? user) {
    final _nombreController = TextEditingController(text: user?.nombre ?? '');
    final _emailController = TextEditingController(text: user?.email ?? '');
    final _telefonoController = TextEditingController(text: user?.telefono ?? '');
    final _direccionController = TextEditingController(text: user?.direccion ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Añadir Usuario' : 'Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _direccionController,
                decoration: InputDecoration(labelText: 'Dirección'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(user == null ? 'Guardar' : 'Actualizar'),
              onPressed: () async {
                if (user == null) {
                  await userController.createUser(UserModel(
                    id: 'uuid', // Supabase lo genera automáticamente
                    nombre: _nombreController.text,
                    email: _emailController.text,
                    telefono: _telefonoController.text,
                    direccion: _direccionController.text,
                    fechaCreacion: DateTime.now(),
                  ));
                } else {
                  await userController.updateUser(user.id, {
                    'nombre': _nombreController.text,
                    'email': _emailController.text,
                    'telefono': _telefonoController.text,
                    'direccion': _direccionController.text,
                  });
                }

                setState(() {
                  futureUsers = userController.getUsers();
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String id) async {
    await userController.deleteUser(id);
    setState(() {
      futureUsers = userController.getUsers();
    });
  }
}
