import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;  // Para verificar si estamos en la web
import 'dart:html' as html; // Para la web
import '../Users/UserModel.dart';
import '../Users/UserController.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserController _userController = UserController();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final user = await _userController.getUserById(userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData(Map<String, dynamic> updates) async {
    if (_user != null) {
      await _userController.updateUser(_user!.id, updates);
      _fetchUserData();
    }
  }

  // Método para subir imagen solo si estamos en la web
  Future<void> _uploadImage(dynamic file) async {
    if (kIsWeb) {
      final storage = Supabase.instance.client.storage.from('UserImage');
      final filePath = 'profile_images/${_user!.id}/${file.name}';
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoadEnd.first;
      final data = reader.result as Uint8List;
      final response = await storage.uploadBinary(filePath, data);

      if (response.isNotEmpty) {
        final fileUrl = storage.getPublicUrl(filePath);
        _updateUserData({'photo_url': fileUrl});
      } else {
        // Manejar error
      }
    }
  }

  void _showImagePicker() async {
    if (kIsWeb) { // Solo ejecutamos esto en la web
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files?.isNotEmpty == true) {
          final file = files!.first;
          await _uploadImage(file);
        }
      });
    }
  }

  Future<void> _deleteImage() async {
    if (_user?.photo_url != null) {
      final storage = Supabase.instance.client.storage.from('UserImage');
      final path = _user!.photo_url!.split('/').last;
      final response = await storage.remove([path]);

      if (response.isEmpty) {
        await _updateUserData({'photo_url': null});
      } else {
        // Manejar error
      }
    }
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
                  // Imagen del usuario
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Aquí podemos ampliar la imagen si lo deseas
                      },
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
                  // Botón para añadir o quitar imagen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add_a_photo),
                        onPressed: _showImagePicker,
                      ),
                      if (_user!.photo_url != null)
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: _deleteImage,
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
