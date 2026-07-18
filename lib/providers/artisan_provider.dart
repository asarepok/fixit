import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/artisan_repository.dart';
import 'auth_provider.dart';

// Providers for looking up artisans. Screens read these instead of calling
// ArtisanRepository directly.

final artisanRepositoryProvider = Provider<ArtisanRepository>((ref) {
  return ArtisanRepository(ref.watch(firestoreServiceProvider));
});

// The full list of artisans, no location filtering.
final artisansProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(artisanRepositoryProvider).getArtisans();
});

// Artisans sorted by distance from the customer's own saved location, not
// a fresh GPS read, "nearby" means near where they told the app they are
// (Home's location display / LocationPickerScreen), not wherever the
// device happens to be standing right now. Watching currentUserProfileProvider
// means this recomputes the moment they save a new location, no manual
// refresh anywhere. Throws if no location has been saved yet, screens
// should handle that as a "set your location first" state.
final nearbyArtisansProvider = FutureProvider.autoDispose((ref) async {
  final user = ref.watch(currentUserProfileProvider).valueOrNull;
  final lat = user?.latitude;
  final lng = user?.longitude;
  if (lat == null || lng == null) {
    throw Exception('Set your location to see nearby artisans.');
  }
  return ref.watch(artisanRepositoryProvider).getNearbyArtisans(lat, lng);
});
