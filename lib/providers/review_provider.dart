import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/review_model.dart';
import '../repositories/review_repository.dart';
import 'auth_provider.dart';
import 'payment_provider.dart';
import 'verification_provider.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(
    ref.watch(functionsServiceProvider),
    ref.watch(firestoreServiceProvider),
    ref.watch(storageServiceProvider),
  );
});

// Public reviews for an artisan's profile, live, keyed by artisanId.
final artisanReviewsProvider =
    StreamProvider.autoDispose.family<List<Review>, String>((ref, artisanId) {
  return ref.watch(reviewRepositoryProvider).streamReviewsForArtisan(artisanId);
});

// Whether the signed-in customer has already reviewed this booking, live,
// so the booking detail screen and bookings list flip straight from
// "Rate this job" to "Reviewed" the instant submitReview writes, instead
// of only after the screen happens to rebuild for some other reason.
final hasReviewForBookingProvider =
    StreamProvider.autoDispose.family<bool, String>((ref, bookingId) {
  return ref.watch(reviewRepositoryProvider).streamHasReviewForBooking(bookingId);
});

class ReviewController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submitReview({
    required String bookingId,
    required int rating,
    String comment = "",
    XFile? photo,
  }) async {
    state = const AsyncLoading();
    try {
      final customerId = ref.read(authRepositoryProvider).currentUserId!;
      await ref.read(reviewRepositoryProvider).submitReview(
            bookingId: bookingId,
            customerId: customerId,
            rating: rating,
            comment: comment,
            photo: photo,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final reviewControllerProvider =
    AsyncNotifierProvider<ReviewController, void>(ReviewController.new);
