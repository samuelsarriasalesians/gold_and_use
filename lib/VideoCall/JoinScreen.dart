import 'package:flutter/material.dart';
import 'VideoCallScreen.dart';
import 'dart:math'; // Para generar números aleatorios

class JoinScreen extends StatelessWidget {
  final TextEditingController _channelController = TextEditingController();

  String _generateRandomChannel() {
    final random = Random();
    return 'sala_${random.nextInt(100000)}';
  }

  void _joinChannel(BuildContext context, String channelName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(channelName: channelName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unirse o Crear Sala'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _channelController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Sala',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final channelName = _channelController.text.trim();
                if (channelName.isNotEmpty) {
                  _joinChannel(context, channelName);
                }
              },
              child: const Text('Entrar a Sala'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final randomChannel = _generateRandomChannel();
                _joinChannel(context, randomChannel);
              },
              child: const Text('Crear Sala Aleatoria 🚀'),
            ),
          ],
        ),
      ),
    );
  }
}
