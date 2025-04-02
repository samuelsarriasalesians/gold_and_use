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
    const url = 'https://www.goldapi.io/api/XAU/USD';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-access-token': apiKey,
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final price = double.tryParse(jsonData['price'].toString());

      if (price != null) {
        setState(() {
          _latestPrice = price;
          _data.add(FlSpot(_data.length.toDouble(), price));
        });
      }
    } else {
      print('Error obteniendo precio del oro: ${response.statusCode}');
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
              '\$_${_latestPrice!.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(_buildChartData()),
          ),
        ],
      ),
    );
  }
}
