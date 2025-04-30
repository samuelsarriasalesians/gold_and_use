import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  }

  Future<void> _fetchGoldPrice() async {
    const apiKey = '2322844cf20475d079b0145ad8456b0c';
    final now = DateTime.now();
    final start = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 180)));
    final end = DateFormat('yyyy-MM-dd').format(now);

    final url = 'https://api.metalpriceapi.com/v1/timeframe?api_key=$apiKey&start_date=$start&end_date=$end&base=EUR&currencies=XAU';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final Map<String, dynamic> prices = jsonData['rates'] ?? {};

        List<String> sortedDates = prices.keys.toList()..sort();
        List<FlSpot> spots = [];

        for (int i = 0; i < sortedDates.length; i++) {
          final day = sortedDates[i];
          final dayData = prices[day];
          final double? xauPrice = dayData != null ? dayData['XAU']?.toDouble() : null;

          if (xauPrice != null && xauPrice > 0) {
            double eurPerOunce = 1 / xauPrice;
            double eurPerGram = eurPerOunce / 31.1035;
            spots.add(FlSpot(i.toDouble(), eurPerGram));
          }
        }

        setState(() {
          _data = spots;
          _latestPrice = spots.isNotEmpty ? spots.last.y : null;
        });
      } else {
        print('Error API: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción cargando precio oro: $e');
    }
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: _data,
          isCurved: true,
          color: Colors.amber,
          barWidth: 3,
          dotData: const FlDotData(show: false),
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
            title: const Text('Precio del Oro', style: TextStyle(color: Colors.amber)),
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
                '€${_latestPrice!.toStringAsFixed(2)} / g',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              )
            else
              const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _data.isNotEmpty
                  ? LineChart(_buildChartData())
                  : const Center(child: Text('Cargando datos...', style: TextStyle(color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }
}
