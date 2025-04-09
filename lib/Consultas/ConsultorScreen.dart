import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/ConsultorService.dart';
import 'ConsultorModel.dart';

class ConsultorScreen extends StatefulWidget {
  const ConsultorScreen({Key? key}) : super(key: key);

  @override
  _ConsultorScreenState createState() => _ConsultorScreenState();
}

class _ConsultorScreenState extends State<ConsultorScreen> {
  final ConsultorService _service = ConsultorService();
  List<ConsultorModel> _consultas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsultas();
  }

  Future<void> _loadConsultas() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final consultas = await _service.getConsultasByUser(userId);
      setState(() {
        _consultas = consultas;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Consultas'),
        foregroundColor: Colors.black,
        backgroundColor: Colors.amber,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _consultas.isEmpty
              ? const Center(child: Text('No tienes consultas todavía.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _consultas.length,
                  itemBuilder: (context, index) {
                    final consulta = _consultas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: consulta.imagenUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  consulta.imagenUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                        title: Text(
                          consulta.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Peso: ${consulta.peso} g'),
                            Text('Valor calculado: \$${consulta.valor.toStringAsFixed(2)}'),
                            if (consulta.mensaje != null && consulta.mensaje!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Mensaje: ${consulta.mensaje}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                          ],
                        ),
                        onTap: () => _showConsultaDetalle(consulta),
                      ),
                    );
                  },
                ),
    );
  }

  void _showConsultaDetalle(ConsultorModel consulta) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(consulta.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (consulta.imagenUrl != null)
              Center(
                child: Image.network(
                  consulta.imagenUrl!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 10),
            Text('Peso: ${consulta.peso} g'),
            Text('Valor calculado: \$${consulta.valor.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            if (consulta.mensaje != null && consulta.mensaje!.isNotEmpty)
              Text('Mensaje:\n${consulta.mensaje}'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}
