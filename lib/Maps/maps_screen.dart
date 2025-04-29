import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/lat long.dart';
import './mapservice.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final MapsController _controller = MapsController();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intercambios de Oro - Barcelona'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFFFD700),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar intercambios...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchExchanges,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _controller.barcelonaCenter,
                    zoom: _controller.defaultZoom,
                    maxZoom: 17.4,
                    minZoom: 3,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                      retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
                    ),
                    MarkerLayer(
                      markers: _controller.goldExchanges.map((exchange) {
                        return Marker(
                          width: 100,
                          height: 100,
                          point: exchange['position'],
                          builder: (ctx) => GestureDetector(
                            onTap: () {
                              _showExchangeDetails(context, exchange);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.currency_exchange,
                                  color: Color(0xFFFFD700),
                                  size: 40,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    exchange['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Positioned(
                  right: 16.0,
                  bottom: 80.0,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoomIn',
                        mini: true,
                        backgroundColor: const Color(0xFFFFD700),
                        onPressed: () {
                          final currentZoom = _mapController.zoom;
                          if (currentZoom < 17.4) {
                            _mapController.move(
                              _mapController.center,
                              currentZoom + 1,
                            );
                          }
                        },
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'zoomOut',
                        mini: true,
                        backgroundColor: const Color(0xFFFFD700),
                        onPressed: () {
                          final currentZoom = _mapController.zoom;
                          if (currentZoom > 3) {
                            _mapController.move(
                              _mapController.center,
                              currentZoom - 1,
                            );
                          }
                        },
                        child: const Icon(Icons.remove, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapController.move(
          _controller.barcelonaCenter,
          _controller.defaultZoom,
        ),
        backgroundColor: const Color(0xFFFFD700),
        child: const Icon(Icons.center_focus_strong, color: Colors.black),
      ),
    );
  }

  void _searchExchanges() {
    final results = _controller.searchExchanges(_searchController.text);
    if (results.isNotEmpty) {
      _mapController.move(results.first['position'], _controller.defaultZoom);
      _showExchangeDetails(context, results.first);
    }
  }

  void _showExchangeDetails(
      BuildContext context, Map<String, dynamic> exchange) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exchange['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dirección: ${exchange['address']}'),
            const SizedBox(height: 10),
            const Text('Horario: 9:00 - 20:00 (L-V)'),
            const SizedBox(height: 10),
            const Text('Servicios: Compra y venta de oro'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}