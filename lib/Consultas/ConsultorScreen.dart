import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/ConsultorService.dart';
import 'ConsultorModel.dart';

class ConsultorScreen extends StatefulWidget {
  const ConsultorScreen({super.key});

  @override
  State<ConsultorScreen> createState() => _ConsultorScreenState();
}

class _ConsultorScreenState extends State<ConsultorScreen> {
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController mensajeController = TextEditingController();
  File? _imagen;
  bool _isLoading = false;
  final _service = ConsultorService();

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _imagen = File(pickedFile.path));
    }
  }

  Future<void> _enviarConsulta() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || pesoController.text.isEmpty || _imagen == null) return;

    setState(() => _isLoading = true);
    final peso = double.tryParse(pesoController.text.trim()) ?? 0;

    final precioOro = await _service.getPrecioOroGramo(); // usa API real
    final double valor = peso * (precioOro ?? 0);

    final success = await _service.enviarConsulta(
      userId: user.id,
      nombre: user.userMetadata?['name'] ?? 'Sin nombre',
      peso: peso,
      valor: valor,
      imagen: _imagen!,
      mensaje: mensajeController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                success ? 'Consulta enviada' : 'Error al enviar consulta')),
      );
      if (success) {
        pesoController.clear();
        mensajeController.clear();
        setState(() => _imagen = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar consulta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: pesoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Peso (g)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: mensajeController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Mensaje'),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  if (_imagen != null) Image.file(_imagen!, height: 150),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _tomarFoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tomar foto'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _enviarConsulta,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar Consulta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
