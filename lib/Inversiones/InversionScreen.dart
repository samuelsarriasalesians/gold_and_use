import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'InversionModel.dart';
import 'InversionService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InversionScreen extends StatefulWidget {
  const InversionScreen({super.key});

  @override
  State<InversionScreen> createState() => _InversionScreenState();
}

class _InversionScreenState extends State<InversionScreen> {
  List<InversionModel> _inversiones = [];
  bool _loading = true;
  double? _precioOroEurGramo;
  final String userId = Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadInversiones();
    _loadGoldPrice();
    // InversionService.actualizarRendimientosSemanales();
  }

  Future<void> _loadInversiones() async {
    final data = await InversionService.getInversionesByUser(userId);
    setState(() {
      _inversiones = data;
      _loading = false;
    });
  }

  Future<void> _loadGoldPrice() async {
    const apiKey = '2322844cf20475d079b0145ad8456b0c';
    const url = 'https://api.metalpriceapi.com/v1/latest?api_key=$apiKey&base=EUR&currencies=XAU';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final xau = jsonData['rates']['XAU'];
        if (xau != null && xau > 0) {
          final eurPerOunce = 1 / xau;
          final eurPerGram = eurPerOunce / 31.1035;
          setState(() {
            _precioOroEurGramo = eurPerGram;
          });
        }
      }
    } catch (e) {
      print('Error cargando precio del oro: $e');
    }
  }

  Widget _buildCard(InversionModel inv) {
    final isActiva = inv.estado == 'activa';
    final Color cardColor = isActiva ? Colors.green.shade50 : Colors.grey.shade200;
    return Card(
      color: cardColor,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          '€${inv.cantidad.toStringAsFixed(2)} invertidos',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Rendimiento: ${inv.rendimiento.toStringAsFixed(2)}%'),
            Text('Inicio: ${inv.fechaInicio.toLocal().toString().split(" ")[0]}'),
            Text('Fin: ${inv.fechaFin?.toLocal().toString().split(" ")[0] ?? 'No finalizada'}'),
            Text('Estado: ${inv.estado}'),
          ],
        ),
        trailing: isActiva
            ? IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () async {
                  final success = await InversionService.cerrarInversion(inv.id, DateTime.parse(userId));
                  if (success) _loadInversiones();
                },
              )
            : const Icon(Icons.check_circle, color: Colors.grey),
      ),
    );
  }

  void _mostrarDialogoNuevaInversion() {
    final cantidadController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nueva Inversión en Oro"),
        content: _precioOroEurGramo == null
            ? const Text("Cargando precio del oro...")
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Precio actual del oro: €${_precioOroEurGramo!.toStringAsFixed(2)} / gramo"),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cantidadController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Cantidad a invertir en €"),
                  ),
                ],
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final cantidad = double.tryParse(cantidadController.text);
              if (cantidad != null && _precioOroEurGramo != null) {
                final inversion = InversionModel(
                  id: 0,
                  usuarioId: userId,
                  cantidad: cantidad,
                  rendimiento: 0,
                  fechaInicio: DateTime.now(),
                  fechaFin: null,
                  estado: 'activa',
                );
                final success = await InversionService.agregarInversion(inversion);
                if (success) {
                  Navigator.pop(context);
                  _loadInversiones();
                }
              }
            },
            child: const Text("Invertir"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Inversiones de Oro"),
        backgroundColor: Colors.amber.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Nueva inversión',
            onPressed: _mostrarDialogoNuevaInversion,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _inversiones.isEmpty
              ? const Center(child: Text("No tienes inversiones registradas."))
              : ListView.builder(
                  itemCount: _inversiones.length,
                  itemBuilder: (context, index) => _buildCard(_inversiones[index]),
                ),
    );
  }
}
