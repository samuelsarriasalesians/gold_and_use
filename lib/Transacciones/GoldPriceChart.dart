import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

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
    const apiKey = '2322844cf20475d079b0145ad8456b0c';
    const url = 'https://api.metalpriceapi.com/v1/latest?api_key=$apiKey&base=EUR&currencies=XAU';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final xau = jsonData['rates']['XAU'];

        if (xau != null && xau > 0) {
          final eurPerOunce = 1 / xau; // Precio en EUR por onza
          final eurPerKg = eurPerOunce * 32.1507; // 1 kg = 32.1507 oz t

          setState(() {
            _latestPrice = eurPerKg;
            _data.add(FlSpot(_data.length.toDouble(), eurPerKg));
          });
        }
      } else {
        print('Error de API: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print("Excepción en la petición de oro: $e");
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
          color: Colors.amber,
          barWidth: 3,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(show: false),
        )
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
            title: Text("Precio del oro", style: TextStyle(color: Colors.amber)),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _data.isNotEmpty
                  ? LineChart(_buildChartData())
                  : const Center(child: Text("Cargando datos...")),
            ),
          ],
        ),
      ),
    );
  }
}
