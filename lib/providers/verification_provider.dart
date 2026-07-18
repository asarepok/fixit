import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/verification_model.dart';
import '../repositories/verification_repository.dart';
import '../services/storage_service.dart';
import 'auth_provider.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository(
    ref.watch(firestoreServiceProvider),
    ref.watch(storageServiceProvider),
  );
});

// The signed-in user's own Become an Artisan application, live, if
// they've submitted one, for the application status screen.
final myApplicationProvider =
    StreamProvider.autoDispose<VerificationRequest?>((ref) {
  final uid = ref.watch(authRepositoryProvider).currentUserId;
  if (uid == null) return Stream.value(null);
  return ref.watch(verificationRepositoryProvider).streamMyApplication(uid);
});

// The admin review queue, live.
final pendingApplicationsProvider =
    StreamProvider.autoDispose<List<VerificationRequest>>((ref) {
  return ref.watch(verificationRepositoryProvider).streamPendingApplications();
});

class VerificationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submitApplication({
    required String profession,
    required String bio,
    required XFile document,
  }) async {
    state = const AsyncLoading();
    try {
      final uid = ref.read(authRepositoryProvider).currentUserId!;
      await ref.read(verificationRepositoryProvider).submitApplication(
            artisanId: uid,
            profession: profession,
            bio: bio,
            document: document,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Admin only.
  Future<void> reviewApplication({
    required String requestId,
    required String artisanId,
    required bool approved,
    String? note,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(verificationRepositoryProvider).reviewApplication(
            requestId: requestId,
            artisanId: artisanId,
            approved: approved,
            note: note,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final verificationControllerProvider =
    AsyncNotifierProvider<VerificationController, void>(VerificationController.new);
