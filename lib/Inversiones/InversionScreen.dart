import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'InversionModel.dart';
import 'InversionService.dart';
import 'InversionValidationService.dart';

class InversionScreen extends StatefulWidget {
  const InversionScreen({super.key});

  @override
  State<InversionScreen> createState() => _InversionScreenState();
}

class _InversionScreenState extends State<InversionScreen> {
  final String userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  List<InversionModel> _activas = [], _completadas = [];
  Map<int, double> _gananciaPorInversion = {};
  bool _loading = true;
  double? _precioOro;
  bool _mostrarActivas = false;
  bool _mostrarCompletadas = false;

  @override
  void initState() {
    super.initState();
    _cargarPrecioOro();
    _cargarInversiones();
    InversionService.actualizarRendimientosSemanales();
  }

  Future<void> _cargarPrecioOro() async {
    try {
      final String raw = await DefaultAssetBundle.of(context).loadString('lib/assets/gold_price_data.json');
      final List data = json.decode(raw);
      final today = DateTime.now().toIso8601String().split('T')[0];
      final item = data.firstWhere((e) => e['date'] == today, orElse: () => data.last);
      setState(() => _precioOro = item['price'].toDouble());
    } catch (e) {
      print("Error cargando oro: $e");
    }
  }

  Future<void> _cargarInversiones() async {
    final todas = await InversionService.getInversionesByUser(userId);
    final activas = todas.where((i) => i.estado == 'activa').toList();
    final completadas = todas.where((i) => i.estado == 'completada').toList();

    final Map<int, double> ganancias = {};
    for (final inv in todas) {
      final ganancia = await InversionService.calcularGananciaPorcentualDesdeOro(inv.fechaInicio);
      if (ganancia != null) ganancias[inv.id] = ganancia;
    }

    setState(() {
      _activas = activas;
      _completadas = completadas;
      _gananciaPorInversion = ganancias;
      _loading = false;
    });
  }

  Future<void> _crearNuevaInversion() async {
    final TextEditingController _controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Nueva Inversión", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_precioOro != null)
              Text("Precio actual: €${_precioOro!.toStringAsFixed(2)} / g"),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Cantidad a invertir en €"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              child: const Text("Confirmar inversión"),
              onPressed: () async {
                final cantidad = double.tryParse(_controller.text);
                if (cantidad != null) {
                  final valido = await InversionValidationService.validarSaldoDisponible(userId, cantidad);
                  if (!valido) {
                    Navigator.pop(context);
                    _mostrarMensaje("Saldo insuficiente.");
                    return;
                  }
                  final confirm = await _confirmar("¿Deseas invertir €$cantidad?");
                  if (confirm) {
                    final nueva = InversionModel(
                      id: 0,
                      usuarioId: userId,
                      cantidad: cantidad,
                      rendimiento: 0,
                      fechaInicio: DateTime.now(),
                      fechaFin: null,
                      estado: 'activa',
                    );
                    final ok = await InversionService.agregarInversion(nueva);
                    Navigator.pop(context);
                    if (ok) _cargarInversiones();
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmar(String texto) async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Confirmación"),
            content: Text(texto),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Aceptar"))
            ],
          ),
        ) ??
        false;
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildCard(InversionModel inv) {
    final isActiva = inv.estado == 'activa';
    final Color cardColor = isActiva ? Colors.amber.shade50 : Colors.grey.shade100;
    final double? ganancia = _gananciaPorInversion[inv.id];

    return Card(
      color: cardColor,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '€${inv.cantidad.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (isActiva)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    onPressed: () async {
                      final confirm = await _confirmar("¿Finalizar esta inversión?");
                      if (confirm) {
                        final ok = await InversionService.cerrarInversion(inv);
                        if (ok) _cargarInversiones();
                      }
                    },
                  )
              ],
            ),
            const SizedBox(height: 6),
            Text('Rendimiento acumulado: ${inv.rendimiento.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 14)),
            if (ganancia != null)
              Text('📈 Evolución del oro: ${ganancia >= 0 ? '+' : ''}${ganancia.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 14, color: Colors.amber)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Inicio: ${inv.fechaInicio.toLocal().toString().split(" ")[0]}'),
                Text('Estado: ${inv.estado}')
              ],
            ),
            if (inv.fechaFin != null)
              Text('Fin: ${inv.fechaFin!.toLocal().toString().split(" ")[0]}', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(String titulo, List<InversionModel> lista, bool expandido, Function toggle) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ExpansionTile(
        initiallyExpanded: expandido,
        onExpansionChanged: (_) => toggle(),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: lista.isEmpty ? [const Padding(padding: EdgeInsets.all(8), child: Text("Sin inversiones."))] : lista.map(_buildCard).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inversiones de Oro"),
        actions: [
          IconButton(onPressed: _crearNuevaInversion, icon: const Icon(Icons.add_circle_outline))
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildLista("Activas", _activas, _mostrarActivas, () => setState(() => _mostrarActivas = !_mostrarActivas)),
                _buildLista("Completadas", _completadas, _mostrarCompletadas, () => setState(() => _mostrarCompletadas = !_mostrarCompletadas)),
              ],
            ),
    );
  }
}
