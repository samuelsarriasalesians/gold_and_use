import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'TransaccioneService.dart';
import '../Users/UserModel.dart';

class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransaccionController _controller = TransaccionController();
  String? selectedWeightUnit = 'g';
  String? selectedPurity = '24K';
  TextEditingController weightController = TextEditingController();
  TextEditingController messageController =
      TextEditingController(); // 🔥 Bloque de texto para mensaje
  double? calculatedPrice = 0.0;
  File? _image;

  @override
  void initState() {
    super.initState();
    _fetchGoldPrice();
  }

  Future<void> _fetchGoldPrice() async {
    await _controller.fetchGoldPrice();
    setState(() {});
  }

  void _calculatePrice() {
    double weight = double.tryParse(weightController.text) ?? 0.0;
    if (weight > 0) {
      setState(() {
        calculatedPrice = _controller.calculateGoldPrice(
            weight, selectedPurity!, selectedWeightUnit!);
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Ingrese un peso válido")));
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveConsultor() async {
    final user = UserModel(
      id: Supabase.instance.client.auth.currentUser!.id,
      nombre: '',
      email: Supabase.instance.client.auth.currentUser!.email ?? '',
      telefono: null,
      direccion: null,
      fechaCreacion: DateTime.now(),
      isAdmin: false,
      photo_url: null,
    );

    // Subir imagen
    String? imageUrl;
    if (_image != null) {
      imageUrl = await _controller.uploadImage(_image!, user);
    }

    // Obtener número de consultas existentes
    final List data =
        await Supabase.instance.client.from('consultor').select('id');

    final int count = data.length;

    final nombreConsulta =
        'Consulta #${(count + 1).toString().padLeft(3, '0')}';

    // Insertar datos en la tabla consultor
    await Supabase.instance.client.from('consultor').insert({
      'usuario_id': user.id,
      'nombre': nombreConsulta,
      'peso': double.tryParse(weightController.text) ?? 0.0,
      'valor': calculatedPrice ?? 0.0,
      'imagen_url': imageUrl,
      'mensaje': messageController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Consulta guardada exitosamente')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultoría', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/logo.png', width: 150)),
            SizedBox(height: 20),
            Text('Peso del Oro',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Ingrese peso'),
                  ),
                ),
                DropdownButton<String>(
                  value: selectedWeightUnit,
                  items: ['g', 'kg', 'oz', 'lb']
                      .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedWeightUnit = value),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Pureza del Oro',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedPurity,
              items: ['24K', '22K', '18K', '14K']
                  .map((purity) => DropdownMenuItem(
                        value: purity,
                        child: Text(purity),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedPurity = value),
            ),
            SizedBox(height: 20),
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(
                'Precio del Oro: \$${calculatedPrice?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(fontSize: 18),
              )),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculatePrice,
              child: Text('Calcular'),
            ),
            SizedBox(height: 20),
            Center(
              child: IconButton(
                icon: Icon(Icons.camera_alt, size: 40),
                onPressed: _takePicture,
              ),
            ),
            if (_image != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Image.file(_image!, height: 150),
                ),
              ),
            SizedBox(height: 20),
            Text('Mensaje para el asesor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe aquí tu consulta...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveConsultor,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text('Enviar Consulta'),
            ),
          ],
        ),
      ),
    );
  }
}
