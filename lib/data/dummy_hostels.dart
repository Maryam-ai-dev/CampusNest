import '../models/hostel.dart';

/// Temporary data. Replace with Firestore `hostels` later.
const List<Hostel> dummyHostels = [
  Hostel(
    id: 'h1',
    name: 'Al-Noor Boys Hostel',
    distanceKm: 0.4,
    rentPerMonth: 18000,
    matchPercent: 92,
    hasMess: true,
    hasAc: true,
    hasWifi: true,
  ),
  Hostel(
    id: 'h2',
    name: 'Green Valley Residency',
    distanceKm: 0.9,
    rentPerMonth: 22000,
    matchPercent: 78,
    hasWifi: true,
  ),
  Hostel(
    id: 'h3',
    name: 'City View Hostel',
    distanceKm: 1.2,
    rentPerMonth: 16500,
    matchPercent: 85,
    hasAc: true,
  ),
];