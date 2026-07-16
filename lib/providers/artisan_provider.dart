import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/artisan_repository.dart';
import 'auth_provider.dart';
import 'location_provider.dart';

// Providers for looking up artisans. Screens read these instead of calling
// ArtisanRepository directly.

final artisanRepositoryProvider = Provider<ArtisanRepository>((ref) {
  return ArtisanRepository(ref.watch(firestoreServiceProvider));
});

// The full list of artisans, no location filtering.
final artisansProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(artisanRepositoryProvider).getArtisans();
});

// Artisans sorted by distance from the device's current position. Watch
// this on the nearby artisans screen. It depends on currentPositionProvider,
// so it will show a loading state while the device's location is being
// read, and an error state if location access fails or is denied.
final nearbyArtisansProvider = FutureProvider.autoDispose((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  return ref.watch(artisanRepositoryProvider).getNearbyArtisans(position);
});
