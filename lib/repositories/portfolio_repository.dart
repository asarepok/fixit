import 'package:image_picker/image_picker.dart';

import '../models/portfolio_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

const _portfolioCollection = "portfolio";

// An artisan's "my work" gallery: uploading a photo, removing one, and
// the live list shown on their public profile.
class PortfolioRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  PortfolioRepository(this._firestoreService, this._storageService);

  // Uploads the photo, then records it, in that order, so a doc never
  // points at a file that doesn't exist yet.
  Future<void> addPhoto({
    required String artisanId,
    required XFile photo,
  }) async {
    final imageUrl = await _storageService.uploadFile(
      "portfolio_photos/$artisanId/${DateTime.now().millisecondsSinceEpoch}.jpg",
      photo,
    );

    final item = PortfolioItem(id: "", artisanId: artisanId, imageUrl: imageUrl);
    final data = item.toCreateMap();
    data["createdAt"] = DateTime.now().toUtc();

    await _firestoreService.addDocument(_portfolioCollection, data);
  }

  // Removes both the Firestore record and the underlying file. The
  // record is what every screen actually reacts to, so it goes first,
  // the storage cleanup happens after and doesn't block the UI update.
  Future<void> deletePhoto({required String id, required String imageUrl}) async {
    await _firestoreService.deleteDocument(_portfolioCollection, id);
    await _storageService.deleteFileByUrl(imageUrl);
  }

  // An artisan's gallery, live, newest first.
  Stream<List<PortfolioItem>> streamPortfolio(String artisanId) {
    return _firestoreService
        .streamCollectionWhere(
          _portfolioCollection,
          "artisanId",
          artisanId,
          orderBy: "createdAt",
          descending: true,
        )
        .map((docs) => docs.map(PortfolioItem.fromMap).toList());
  }
}
