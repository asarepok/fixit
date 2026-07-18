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

// The signed-in user's own profile as a UserModel, live. Watch this in
// any screen that displays or depends on "my profile", for example the
// artisan dashboard's balance card, it updates on its own the moment the
// underlying document changes (a release crediting a balance, an admin
// approving an application, ...), no manual refresh or invalidate needed.
final currentUserProfileProvider = StreamProvider.autoDispose<UserModel?>((
  ref,
) {
  final uid = ref.watch(authStateProvider).valueOrNull;
  if (uid == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).streamUserProfile(uid);
});

// Every account, live, for the admin Manage Users screen.
final allUsersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return ref.watch(authRepositoryProvider).streamAllUsers();
});

// A single user by uid, live, for admin screens showing a name next to a
// customer/artisan/applicant id, keyed by that uid.
final userByIdProvider =
    StreamProvider.autoDispose.family<UserModel?, String>((ref, uid) {
  return ref.watch(authRepositoryProvider).streamUserById(uid);
});

// Handles login, register, logout, and profile updates for the signed-in
// user. A screen calls a method here to perform the action, and watches
// ref.watch(authControllerProvider) to know if it is currently loading or
// hit an error, for example to show a spinner or a message.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Signs the user in, then loads their profile. The login screen uses
  // this to decide where to land them: admins go to the admin dashboard,
  // verified artisans open straight into artisan mode, everyone else
  // opens Home.
  Future<UserModel?> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.login(email, password);
      final user = await repo.getCurrentUserProfile();
      state = const AsyncData(null);
      return user;
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
    String? momoNetwork,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final uid = repo.currentUserId!;
      await repo.updateProfile(
        uid: uid,
        name: name,
        phone: phone,
        momoNetwork: momoNetwork,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Saves the signed-in user's current location, called from the Home
  // screen's location display and the profile screen's "My Location"
  // row. Does not set a loading state, both callers show their own
  // snackbar instead of a spinner.
  Future<void> updateMyLocation(double latitude, double longitude, {String? label}) async {
    final repo = ref.read(authRepositoryProvider);
    final uid = repo.currentUserId!;
    await repo.updateMyLocation(uid: uid, latitude: latitude, longitude: longitude, label: label);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
