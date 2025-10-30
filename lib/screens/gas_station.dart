class GasStation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double distance;
  final Map<String, double> prices;
  final String address;

  GasStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.prices,
    required this.address,
  });

  double get cheapestPrice {
    if (prices.isEmpty) return 0.0;
    return prices.values.reduce((a, b) => a < b ? a : b);
  }
}

List<GasStation> getSampleGasStations() {
  return [
    GasStation(
      id: '1',
      name: 'Shell',
      latitude: 30.4150,
      longitude: -91.1800,
      distance: 0.5,
      prices: {
        'Regular': 2.89,
        'Mid-Grade': 3.19,
        'Premium': 3.49,
        'Diesel': 3.29,
      },
      address: '1234 Highland Rd, Baton Rouge, LA',
    ),
    GasStation(
      id: '2',
      name: 'Chevron',
      latitude: 30.4100,
      longitude: -91.1850,
      distance: 0.8,
      prices: {
        'Regular': 2.85,
        'Mid-Grade': 3.15,
        'Premium': 3.45,
        'Diesel': 3.25,
      },
      address: '5678 Perkins Rd, Baton Rouge, LA',
    ),
    GasStation(
      id: '3',
      name: 'Exxon',
      latitude: 30.4180,
      longitude: -91.1780,
      distance: 1.2,
      prices: {
        'Regular': 2.92,
        'Mid-Grade': 3.22,
        'Premium': 3.52,
        'Diesel': 3.32,
      },
      address: '9012 Tiger Bend Rd, Baton Rouge, LA',
    ),
    GasStation(
      id: '4',
      name: 'BP',
      latitude: 30.4120,
      longitude: -91.1900,
      distance: 1.5,
      prices: {
        'Regular': 2.87,
        'Mid-Grade': 3.17,
        'Premium': 3.47,
        'Diesel': 3.27,
      },
      address: '3456 Burbank Dr, Baton Rouge, LA',
    ),
    GasStation(
      id: '5',
      name: 'Circle K',
      latitude: 30.4090,
      longitude: -91.1820,
      distance: 1.8,
      prices: {
        'Regular': 2.79,
        'Mid-Grade': 3.09,
        'Premium': 3.39,
        'Diesel': 3.19,
      },
      address: '7890 Essen Ln, Baton Rouge, LA',
    ),
  ];
}