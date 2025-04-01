import 'package:flutter/material.dart';
import 'UserService.dart';
import 'UserModel.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserService userService = UserService();
  late Future<List<UserModel>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = userService.getUsers();
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
    final _telefonoController =
        TextEditingController(text: user?.telefono ?? '');
    final _direccionController =
        TextEditingController(text: user?.direccion ?? '');

    bool _isAdmin = user?.isAdmin ?? false; // Inicializamos el valor de isAdmin

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Añadir Usuario' : 'Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Agregamos Padding alrededor de cada TextField para un pequeño espacio
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0), // Ajusta el valor
                child: TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12), // Espacio interno
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0), // Ajusta el valor
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12), // Espacio interno
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0), // Ajusta el valor
                child: TextField(
                  controller: _telefonoController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12), // Espacio interno
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0), // Ajusta el valor
                child: TextField(
                  controller: _direccionController,
                  decoration: InputDecoration(
                    labelText: 'Dirección',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12), // Espacio interno
                  ),
                ),
              ),
              // DropdownButton para el campo 'isAdmin'
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<bool>(
                  value: _isAdmin,
                  onChanged: (newValue) {
                    setState(() {
                      _isAdmin = newValue!;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      child: Text('Administrador'),
                      value: true,
                    ),
                    DropdownMenuItem(
                      child: Text('No Administrador'),
                      value: false,
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Administrador',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12), // Espacio interno
                  ),
                ),
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
                  await userService.createUser(UserModel(
                    id: 'uuid', // Supabase lo genera automáticamente
                    nombre: _nombreController.text,
                    email: _emailController.text,
                    telefono: _telefonoController.text,
                    direccion: _direccionController.text,
                    fechaCreacion: DateTime.now(),
                    isAdmin: _isAdmin, // Usamos el valor booleano aquí
                  ));
                } else {
                  await userService.updateUser(user.id, {
                    'nombre': _nombreController.text,
                    'email': _emailController.text,
                    'telefono': _telefonoController.text,
                    'direccion': _direccionController.text,
                    'isAdmin': _isAdmin, // Usamos el valor booleano aquí también
                  });
                }

                setState(() {
                  futureUsers = userService.getUsers();
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
    await userService.deleteUser(id);
    setState(() {
      futureUsers = userService.getUsers();
    });
  }
}
