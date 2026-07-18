import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/portfolio_model.dart';
import '../repositories/portfolio_repository.dart';
import 'auth_provider.dart';
import 'verification_provider.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository(
    ref.watch(firestoreServiceProvider),
    ref.watch(storageServiceProvider),
  );
});

// An artisan's "my work" gallery, live, keyed by artisanId. Watched both
// on the artisan's own Manage Portfolio screen and on the public artisan
// profile a customer sees.
final portfolioProvider =
    StreamProvider.autoDispose.family<List<PortfolioItem>, String>((ref, artisanId) {
  return ref.watch(portfolioRepositoryProvider).streamPortfolio(artisanId);
});

class PortfolioController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addPhoto(XFile photo) async {
    state = const AsyncLoading();
    try {
      final artisanId = ref.read(authRepositoryProvider).currentUserId!;
      await ref.read(portfolioRepositoryProvider).addPhoto(
            artisanId: artisanId,
            photo: photo,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deletePhoto(PortfolioItem item) async {
    state = const AsyncLoading();
    try {
      await ref.read(portfolioRepositoryProvider).deletePhoto(
            id: item.id,
            imageUrl: item.imageUrl,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final portfolioControllerProvider =
    AsyncNotifierProvider<PortfolioController, void>(PortfolioController.new);
