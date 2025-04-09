import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GoldPriceChart extends StatefulWidget {
  const GoldPriceChart({super.key});

  @override
  State<GoldPriceChart> createState() => _GoldPriceChartState();
}

class _GoldPriceChartState extends State<GoldPriceChart> {
  List<FlSpot> _data = [];
  double? _latestPrice;

  @override
  void initState() {
    super.initState();
    _fetchGoldPrice();
    Timer.periodic(const Duration(hours: 4), (timer) => _fetchGoldPrice());
  }

  Future<void> _fetchGoldPrice() async {
    try {
      final String raw = await DefaultAssetBundle.of(context).loadString('assets/gold_price_data.json');
      final List jsonData = json.decode(raw);

      List<FlSpot> spots = [];
      for (int i = 0; i < jsonData.length; i++) {
        final day = jsonData[i];
        final double price = double.tryParse(day['price'].toString()) ?? 0;
        spots.add(FlSpot(i.toDouble(), price));
      }

      setState(() {
        _data = spots;
        _latestPrice = spots.isNotEmpty ? spots.last.y : null;
      });
    } catch (e) {
      print("Excepción al leer JSON local de oro: $e");
    }
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: _data,
          isCurved: true,
          color: Colors.amber.shade700,
          barWidth: 3,
          dotData: FlDotData(show: false), // 👈 Ocultar los puntos
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.3),
                Colors.amber.withOpacity(0.05)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  void _openFullScreenChart() {
    if (_data.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text("Precio del oro", style: TextStyle(color: Colors.amber)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(_buildChartData()),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openFullScreenChart,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_latestPrice != null)
              Text(
                '€${_latestPrice!.toStringAsFixed(2)} / kg',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              )
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _data.isNotEmpty
                  ? LineChart(_buildChartData())
                  : const Center(
                      child: Text("Cargando datos...", style: TextStyle(color: Colors.white)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
