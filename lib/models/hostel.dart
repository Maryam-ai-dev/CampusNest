class Hostel {
  const Hostel({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.rentPerMonth,
    required this.matchPercent,
    this.hasMess = false,
    this.hasAc = false,
    this.hasWifi = false,
  });

  final String id;
  final String name;
  final double distanceKm;
  final int rentPerMonth;
  final int matchPercent;
  final bool hasMess;
  final bool hasAc;
  final bool hasWifi;
}