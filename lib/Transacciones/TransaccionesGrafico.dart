import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'TransaccionController.dart';
import 'TransaccionModel.dart';

class TransaccionesGrafico extends StatefulWidget {
  final String userId;
  
  const TransaccionesGrafico({Key? key, required this.userId}) : super(key: key);

  @override
  _TransaccionesGraficoState createState() => _TransaccionesGraficoState();
}

class _TransaccionesGraficoState extends State<TransaccionesGrafico> {
  final TransaccionController _transaccionController = TransaccionController();
  List<FlSpot> _compraData = [];
  List<FlSpot> _ventaData = [];

  @override
  void initState() {
    super.initState();
    _loadTransacciones();
  }

  Future<void> _loadTransacciones() async {
    List<TransaccionModel> transacciones = await _transaccionController.getTransacciones();
    
    transacciones = transacciones
        .where((t) => t.usuarioId == widget.userId)
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    setState(() {
      _compraData = transacciones
          .where((t) => t.tipo == "compra")
          .toList().asMap()
          .entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value.total))
          .toList();

      _ventaData = transacciones
          .where((t) => t.tipo == "venta")
          .toList().asMap()
          .entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value.total))
          .toList();
    });
  }

  Widget _buildChart(String title, List<FlSpot> data, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    color: color,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.3)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 250,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _compraData.isEmpty && _ventaData.isEmpty
          ? const Center(child: Text("No hay transacciones disponibles"))
          : Row(
              children: [
                _buildChart("Compras", _compraData, const Color.fromARGB(255, 215, 255, 57)),
                const SizedBox(width: 8), // Espacio pequeño entre gráfico y línea
                Container(
                  width: 1, // Ancho de la línea divisoria
                  color: Colors.black, // Color de la línea divisoria
                ),
                const SizedBox(width: 8), // Espacio pequeño entre línea y gráfico
                _buildChart("Ventas", _ventaData, Colors.red),
              ],
            ),
    );
  }
}