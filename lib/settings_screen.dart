import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes'),
        backgroundColor: Colors.black, // Cambia el color del AppBar aquí
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.notifications, color: Color(0xFFD4AF37)),
            title: Text('Notificaciones'),
            trailing: Switch(value: true, onChanged: (bool value) {}),
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
}