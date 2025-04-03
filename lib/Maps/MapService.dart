import 'package:latlong2/latlong.dart';

class MapsController {
  // Ubicación central (Barcelona)
  final LatLng barcelonaCenter = const LatLng(41.3851, 2.1734);
  final double defaultZoom = 13.0;

  // Lista ampliada de intercambios de oro en Barcelona
  final List<Map<String, dynamic>> goldExchanges = [
    // Centro - Ramblas
    {
      'name': 'Compro Oro Barcelona Centro',
      'position': const LatLng(41.3825, 2.1769),
      'address': 'C/ Pelai, 12',
      'horario': 'L-V: 9:30-20:00, S: 10:00-14:00'
    },
    {
      'name': 'Oro Cash Barcelona',
      'position': const LatLng(41.3808, 2.1731),
      'address': 'La Rambla, 102',
      'horario': 'L-D: 10:00-21:00'
    },

    // Eixample
    {
      'name': 'Casa del Oro - Eixample',
      'position': const LatLng(41.3878, 2.1690),
      'address': 'Rambla Catalunya, 45',
      'horario': 'L-S: 9:00-20:30'
    },
    {
      'name': 'Compraventa Valdés',
      'position': const LatLng(41.3912, 2.1645),
      'address': 'Pg. de Gràcia, 28',
      'horario': 'L-V: 9:00-19:30, S: 10:00-14:00'
    },
    {
      'name': 'Oro y Diamantes',
      'position': const LatLng(41.3943, 2.1612),
      'address': 'C/ Aragó, 256',
      'horario': 'L-V: 9:30-13:30 / 16:30-20:00'
    },

    // Gràcia
    {
      'name': 'Gràcia Compra Oro',
      'position': const LatLng(41.4024, 2.1572),
      'address': 'C/ Verdi, 45',
      'horario': 'L-S: 10:00-14:00 / 17:00-20:30'
    },

    // Sants-Montjuïc
    {
      'name': 'Oro Express Sants',
      'position': const LatLng(41.3746, 2.1358),
      'address': 'C/ Sants, 201',
      'horario': 'L-V: 9:30-13:30 / 16:00-20:00'
    },
    {
      'name': 'Compramos Tu Oro',
      'position': const LatLng(41.3689, 2.1437),
      'address': 'Av. Paral·lel, 158',
      'horario': 'L-S: 10:00-20:00'
    },

    // Sant Martí
    {
      'name': 'Oro Glòries',
      'position': const LatLng(41.4036, 2.1894),
      'address': 'Av. Diagonal, 208',
      'horario': 'L-V: 9:30-13:30 / 16:30-20:00'
    },
    {
      'name': 'Poblenou Compra Oro',
      'position': const LatLng(41.3987, 2.1993),
      'address': 'C/ Bilbao, 78',
      'horario': 'L-V: 10:00-14:00 / 17:00-20:00'
    },

    // Sarrià-Sant Gervasi
    {
      'name': 'Oro Selecto',
      'position': const LatLng(41.3962, 2.1398),
      'address': 'Av. Diagonal, 469',
      'horario': 'L-V: 10:00-14:00 / 16:30-20:00'
    },
    {
      'name': 'Sarrià Oro',
      'position': const LatLng(41.4015, 2.1267),
      'address': 'C/ Major de Sarrià, 35',
      'horario': 'L-S: 10:00-14:00 / 17:00-20:30'
    },

    // Les Corts
    {
      'name': 'Compra Oro Les Corts',
      'position': const LatLng(41.3865, 2.1294),
      'address': 'C/ Numància, 98',
      'horario': 'L-V: 9:30-13:30 / 16:30-20:00'
    },

    // Nou Barris
    {
      'name': 'Oro Norte',
      'position': const LatLng(41.4389, 2.1774),
      'address': 'C/ Via Júlia, 186',
      'horario': 'L-V: 10:00-14:00 / 17:00-20:00'
    }
  ];

  // Método para buscar intercambios por nombre o dirección
  List<Map<String, dynamic>> searchExchanges(String query) {
    if (query.isEmpty) return [];
    
    return goldExchanges.where((exchange) => 
      exchange['name'].toString().toLowerCase().contains(query.toLowerCase()) || 
      exchange['address'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}