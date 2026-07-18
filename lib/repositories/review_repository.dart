import 'package:image_picker/image_picker.dart';

import '../models/review_model.dart';
import '../services/firestore_service.dart';
import '../services/functions_service.dart';
import '../services/storage_service.dart';

const _reviewsCollection = "reviews";

class ReviewRepository {
  final FunctionsService _functionsService;
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  ReviewRepository(
    this._functionsService,
    this._firestoreService,
    this._storageService,
  );

  // Creates the review and updates the artisan's averageRating/ratingCount
  // in one step, via the submitReview Cloud Function, since that needs to
  // touch a field on someone else's user document, not something a plain
  // Firestore rule can safely allow directly from the client. The photo,
  // if any, uploads first, Cloud Functions here never touch Storage, only
  // Firestore, so the URL has to already exist before the call.
  Future<void> submitReview({
    required String bookingId,
    required String customerId,
    required int rating,
    String comment = "",
    XFile? photo,
  }) async {
    String? photoUrl;
    if (photo != null) {
      photoUrl = await _storageService.uploadFile(
        "review_photos/$customerId/${DateTime.now().millisecondsSinceEpoch}.jpg",
        photo,
      );
    }

    await _functionsService.call("submitReview", {
      "bookingId": bookingId,
      "rating": rating,
      "comment": comment,
      "photoUrl": photoUrl,
    });
  }

  // Public reviews for an artisan's profile, live, newest first. Picks up
  // a new review the moment submitReview writes it, no manual refresh.
  Stream<List<Review>> streamReviewsForArtisan(String artisanId) {
    return _firestoreService
        .streamCollectionWhere(
          _reviewsCollection,
          "artisanId",
          artisanId,
          orderBy: "createdAt",
          descending: true,
        )
        .map((docs) => docs.map(Review.fromMap).toList());
  }

  // Whether this booking already has a review, live, so the booking
  // detail screen and bookings list can hide the "Rate Artisan" button
  // the instant one gets submitted instead of sending the customer to a
  // form the Cloud Function will just reject as a dupe.
  Stream<bool> streamHasReviewForBooking(String bookingId) {
    return _firestoreService
        .streamCollectionWhere(_reviewsCollection, "bookingId", bookingId)
        .map((docs) => docs.isNotEmpty);
  }
}
