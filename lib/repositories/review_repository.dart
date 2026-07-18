import '../models/review_model.dart';
import '../services/firestore_service.dart';
import '../services/functions_service.dart';

const _reviewsCollection = "reviews";

class ReviewRepository {
  final FunctionsService _functionsService;
  final FirestoreService _firestoreService;

  ReviewRepository(this._functionsService, this._firestoreService);

  // Creates the review and updates the artisan's averageRating/ratingCount
  // in one step, via the submitReview Cloud Function, since that needs to
  // touch a field on someone else's user document, not something a plain
  // Firestore rule can safely allow directly from the client.
  Future<void> submitReview({
    required String bookingId,
    required int rating,
    String comment = "",
  }) async {
    await _functionsService.call("submitReview", {
      "bookingId": bookingId,
      "rating": rating,
      "comment": comment,
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
}
