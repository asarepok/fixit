import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

// Providers for reading the device's GPS location. Screens should read
// these instead of creating LocationService themselves.

final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());

// The device's current position, read once each time this provider is
// watched or read. Throws if location services are off or permission is
// denied, handle that with an AsyncValue.when error case or a try/catch.
final currentPositionProvider = FutureProvider.autoDispose<Position>((ref) {
  return ref.watch(locationServiceProvider).getCurrentLocation();
});
