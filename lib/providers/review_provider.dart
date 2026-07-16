import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review_model.dart';
import '../repositories/review_repository.dart';
import 'auth_provider.dart';
import 'payment_provider.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(
    ref.watch(functionsServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

// Public reviews for an artisan's profile, keyed by artisanId.
final artisanReviewsProvider =
    FutureProvider.autoDispose.family<List<Review>, String>((ref, artisanId) {
  return ref.watch(reviewRepositoryProvider).getReviewsForArtisan(artisanId);
});

class ReviewController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submitReview({
    required String bookingId,
    required String artisanId,
    required int rating,
    String comment = "",
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(reviewRepositoryProvider).submitReview(
            bookingId: bookingId,
            rating: rating,
            comment: comment,
          );
      ref.invalidate(artisanReviewsProvider(artisanId));
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final reviewControllerProvider =
    AsyncNotifierProvider<ReviewController, void>(ReviewController.new);
