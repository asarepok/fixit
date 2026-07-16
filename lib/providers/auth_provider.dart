import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// Everything a screen needs for auth, the signed-in user's profile, and
// account actions like login, register, and updating a profile. This is
// the file to import from a screen for any of that, screens should not
// create AuthService, FirestoreService, or AuthRepository themselves.

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

// Emits the signed-in user's uid, or null when signed out. Watch this to
// react whenever the user signs in or out.
final authStateProvider = StreamProvider((ref) {
  return ref.watch(authRepositoryProvider).authUidChanges();
});

// The signed-in user's own profile as a UserModel. Watch this in any
// screen that displays or depends on "my profile", for example the profile
// screen. Refreshes automatically when the signed-in user changes, and can
// be refreshed manually with ref.invalidate(currentUserProfileProvider)
// after an update.
final currentUserProfileProvider =
    FutureProvider.autoDispose<UserModel?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).getCurrentUserProfile();
});

// Handles login, register, logout, and profile updates for the signed-in
// user. A screen calls a method here to perform the action, and watches
// ref.watch(authControllerProvider) to know if it is currently loading or
// hit an error, for example to show a spinner or a message.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Signs the user in, then looks up their role. Returns the role
  // ("user" or "admin") so the screen can decide whether to open the admin
  // dashboard, every other account opens Home, artisan mode is a switch
  // from there, not a login-time destination.
  Future<String?> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.login(email, password);
      final role = await repo.getUserRole(repo.currentUserId!);
      state = const AsyncData(null);
      return role;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Creates a new account and its user document. Used by the register
  // screen. Every new account starts as a plain customer, Become an
  // Artisan is a separate, later action, not part of signing up.
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            phone: phone,
            password: password,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
  }

  // Updates the signed-in user's name and phone number. Called from the
  // edit profile screen when the user saves changes.
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final uid = repo.currentUserId!;
      await repo.updateProfile(uid: uid, name: name, phone: phone);
      ref.invalidate(currentUserProfileProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Saves the signed-in user's current location, called from the profile
  // screen's "Update My Location" button. Does not set a loading state
  // since the profile screen shows its own snackbar instead of a spinner.
  Future<void> updateMyLocation(double latitude, double longitude) async {
    final repo = ref.read(authRepositoryProvider);
    final uid = repo.currentUserId!;
    await repo.updateMyLocation(uid: uid, latitude: latitude, longitude: longitude);
    ref.invalidate(currentUserProfileProvider);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
