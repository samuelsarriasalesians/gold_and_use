import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'TransaccioneService.dart';
import '../Users/UserModel.dart'; // Tu modelo de usuario

class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransaccionController _controller = TransaccionController();
  String? selectedWeightUnit = 'g';
  String? selectedPurity = '24K'; // Valor inicial de la pureza
  TextEditingController weightController = TextEditingController();
  double? calculatedPrice = 0.0;
  File? _image;

  @override
  void initState() {
    super.initState();
    _fetchGoldPrice();
  }

  // Obtener el precio del oro cuando se abre la pantalla
  Future<void> _fetchGoldPrice() async {
    await _controller.fetchGoldPrice();
    setState(() {});
  }

  // Método para calcular el precio del oro
  void _calculatePrice() {
    double weight = double.tryParse(weightController.text) ?? 0.0;
    if (weight > 0) {
      setState(() {
        calculatedPrice = _controller.calculateGoldPrice(weight, selectedPurity!, selectedWeightUnit!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ingrese un peso válido")));
    }
  }

  // Método para tomar una foto con la cámara
  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Subir la imagen y guardar la información
  Future<void> _uploadImage() async {
    if (_image != null) {
      final user = UserModel(
        id: Supabase.instance.client.auth.currentUser!.id, // ID del usuario autenticado
        nombre: '',
        email: Supabase.instance.client.auth.currentUser!.email ?? '',
        telefono: null,
        direccion: null,
        fechaCreacion: DateTime.now(),
        isAdmin: false,
        photo_url: null,
      );

      final imageUrl = await _controller.uploadImage(_image!, user);

      if (imageUrl != null) {
        await _controller.saveImageData(user.id, imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Imagen guardada exitosamente")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transacciones', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView( // 🔥 PARA EVITAR EL OVERFLOW
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/logo.png', width: 150)),
            SizedBox(height: 20),

            Text('Peso del Oro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Ingrese peso',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: selectedWeightUnit,
                  items: ['g', 'kg', 'oz', 'lb'].map((unit) => DropdownMenuItem(
                    value: unit,
                    child: Text(unit, style: TextStyle(fontSize: 16)),
                  )).toList(),
                  onChanged: (value) => setState(() => selectedWeightUnit = value),
                ),
              ],
            ),
            SizedBox(height: 20),

            Text('Pureza del Oro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedPurity,
              items: ['24K', '22K', '18K', '14K'].map((purity) => DropdownMenuItem(
                value: purity,
                child: Text(purity, style: TextStyle(fontSize: 16)),
              )).toList(),
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
              child: Center(child: Text(
                'Precio del Oro: \$${calculatedPrice?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(fontSize: 18),
              )),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _calculatePrice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text('Calcular'),
            ),
            SizedBox(height: 20),

            Center(
              child: IconButton(
                icon: Icon(Icons.camera_alt, size: 40, color: Colors.black),
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

            ElevatedButton(
              onPressed: _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text('Guardar Imagen'),
            ),
            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_money, color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Text(
                    'Oro actual: \$${_controller.goldPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
