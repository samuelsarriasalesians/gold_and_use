import 'package:flutter/material.dart';
import '../services/SettingsService.dart';
import '../Users/UserModel.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = await _settingsService.fetchUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _updateUserData(Map<String, dynamic> updates) async {
    await _settingsService.updateUserData(updates);
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes'),
        foregroundColor: Color(0xFFFFD700),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                if (_user != null) ...[
                  Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _user!.photo_url != null
                            ? NetworkImage(_user!.photo_url!)
                            : null,
                        child: _user!.photo_url == null
                            ? Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add_a_photo),
                        onPressed: () => _settingsService.pickAndUploadImage(context, _updateUserData),
                      ),
                      if (_user!.photo_url != null)
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _settingsService.deleteImage(_updateUserData),
                          iconSize: 20,
                        ),
                    ],
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.person, color: Color(0xFFD4AF37)),
                    title: Text('Nombre: ${_user!.nombre}'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editField('Nombre', 'nombre', _user!.nombre),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.email, color: Color(0xFFD4AF37)),
                    title: Text('Email: ${_user!.email}'),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone, color: Color(0xFFD4AF37)),
                    title: Text('Teléfono: ${_user!.telefono ?? "No especificado"}'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editField('Teléfono', 'telefono', _user!.telefono),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home, color: Color(0xFFD4AF37)),
                    title: Text('Dirección: ${_user!.direccion ?? "No especificado"}'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editField('Dirección', 'direccion', _user!.direccion),
                    ),
                  ),
                  Divider(),
                ],
                SwitchListTile(
                  title: Text('Notificaciones'),
                  secondary: Icon(Icons.notifications, color: Color(0xFFD4AF37)),
                  value: true,
                  onChanged: (bool value) {},
                ),
                ListTile(
                  leading: Icon(Icons.lock, color: Color(0xFFD4AF37)),
                  title: Text('Privacidad'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.language, color: Color(0xFFD4AF37)),
                  title: Text('Idioma'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.color_lens, color: Color(0xFFD4AF37)),
                  title: Text('Tema'),
                  onTap: () {},
                ),
              ],
            ),
    );
  }

  void _editField(String title, String fieldKey, String? initialValue) {
    TextEditingController controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Ingrese $title'),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                _updateUserData({fieldKey: controller.text});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}