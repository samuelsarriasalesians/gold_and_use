import 'package:latlong2/latlong.dart';

class MapsController {
  // Ubicación central (Barcelona)
  final LatLng barcelonaCenter = LatLng(41.3851, 2.1734);
  final double defaultZoom = 13.0;

  // Lista de intercambios de oro en Barcelona
  final List<Map<String, dynamic>> goldExchanges = [
    {
      'name': 'Compro Oro Barcelona Centro',
      'position': LatLng(41.3825, 2.1769),
      'address': 'C/ Pelai, 12'
    },
    {
      'name': 'Casa del Oro',
      'position': LatLng(41.3878, 2.1690),
      'address': 'Rambla Catalunya, 45'
    },
    {
      'name': 'Oro Express',
      'position': LatLng(41.3802, 2.1823),
      'address': 'C/ Balmes, 32'
    },
    {
      'name': 'Compraventa Valdés',
      'position': LatLng(41.3912, 2.1645),
      'address': 'Pg. de Gràcia, 28'
    },
  ];

  // Método para buscar intercambios por nombre
  List<Map<String, dynamic>> searchExchanges(String query) {
    return goldExchanges.where((exchange) => 
      exchange['name'].toLowerCase().contains(query.toLowerCase()) || 
      exchange['address'].toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}