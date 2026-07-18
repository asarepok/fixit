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

  // Every user verified as an artisan, with no location filtering. Being
  // an artisan is a capability any customer can apply for, not a separate
  // role, so this filters on artisanStatus rather than role.
  Future<List<UserModel>> getArtisans() async {
    final docs = await _firestoreService.queryWhere(
      _usersCollection,
      "artisanStatus",
      "verified",
    );

    return docs.map(UserModel.fromMap).toList();
  }

  // Artisans who have a saved location, paired with their distance from
  // the given position and sorted closest first. Artisans with no saved
  // location are left out since there is nothing to measure distance from.
  // Takes plain coordinates rather than a geolocator Position, the caller
  // may be sourcing them from a live GPS read or (now, normally) the
  // customer's own saved location.
  Future<List<NearbyArtisan>> getNearbyArtisans(double latitude, double longitude) async {
    final artisans = await getArtisans();

    final nearby = artisans
        .where((a) => a.latitude != null && a.longitude != null)
        .map((a) => NearbyArtisan(
              artisan: a,
              distanceKm: calculateDistanceKm(
                latitude,
                longitude,
                a.latitude!,
                a.longitude!,
              ),
            ))
        .toList();

    nearby.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return nearby;
  }
}
