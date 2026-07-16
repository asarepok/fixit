import 'package:geolocator/geolocator.dart';

import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../utils/helpers.dart';

const _usersCollection = "users";

// Pairs an artisan with their distance from a given position, used by
// getNearbyArtisans below and displayed on the nearby artisans screen.
class NearbyArtisan {
  final UserModel artisan;
  final double distanceKm;

  const NearbyArtisan({required this.artisan, required this.distanceKm});
}

// Looking up artisans: the full list, or the ones near a given position.
class ArtisanRepository {
  final FirestoreService _firestoreService;

  ArtisanRepository(this._firestoreService);

  // Every user with the "artisan" role, with no location filtering.
  Future<List<UserModel>> getArtisans() async {
    final docs = await _firestoreService.queryWhere(
      _usersCollection,
      "role",
      "artisan",
    );

    return docs.map(UserModel.fromMap).toList();
  }

  // Artisans who have a saved location, paired with their distance from
  // the given position and sorted closest first. Artisans with no saved
  // location are left out since there is nothing to measure distance from.
  Future<List<NearbyArtisan>> getNearbyArtisans(Position position) async {
    final artisans = await getArtisans();

    final nearby = artisans
        .where((a) => a.latitude != null && a.longitude != null)
        .map((a) => NearbyArtisan(
              artisan: a,
              distanceKm: calculateDistanceKm(
                position.latitude,
                position.longitude,
                a.latitude!,
                a.longitude!,
              ),
            ))
        .toList();

    nearby.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return nearby;
  }
}
