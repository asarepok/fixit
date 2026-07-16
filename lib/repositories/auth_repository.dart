import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

const _usersCollection = "users";

// Everything about the signed-in user's own account: signing in, signing
// out, registering, reading and updating their profile, role, and saved
// location. This is the class to call for any "my account" action, usually
// through lib/providers/auth_provider.dart rather than directly.
//
// currentUserId and authUidChanges only ever give out a plain String uid,
// never a firebase_auth User object. This keeps the firebase_auth
// dependency contained to AuthService, so repositories, providers, and
// screens never need to import it themselves.
class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository(this._authService, this._firestoreService);

  // Emits the signed-in user's uid whenever they sign in or out, and null
  // when signed out. Used by providers to react to auth changes.
  Stream<String?> authUidChanges() {
    return _authService.authStateChanges().map((user) => user?.uid);
  }

  // The uid of whoever is currently signed in, or null if nobody is.
  String? get currentUserId => _authService.currentUser?.uid;

  // Creates a Firebase Auth account for a new user, then saves their name,
  // email, and phone as a new user document in Firestore with the default
  // "user" role. Throws if account creation fails.
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final firebaseUser = await _authService.register(email, password);

    if (firebaseUser == null) {
      throw Exception("Account creation failed");
    }

    final user = UserModel(
      uid: firebaseUser.uid,
      name: name,
      email: email,
      phone: phone,
      role: "user",
    );

    await _firestoreService.setDocument(
      _usersCollection,
      user.uid,
      user.toMap(),
    );
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email, password);
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  // Loads the signed-in user's own profile as a UserModel, or null if
  // nobody is signed in or their document does not exist yet.
  Future<UserModel?> getCurrentUserProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final data = await _firestoreService.getDocument(_usersCollection, uid);
    if (data == null) return null;

    return UserModel.fromMap(data);
  }

  // Reads a user's role by uid. Used right after login to decide whether
  // to open the admin dashboard, every other account just opens Home,
  // artisan mode is switched into from there, not chosen at login.
  Future<String?> getUserRole(String uid) async {
    final data = await _firestoreService.getDocument(_usersCollection, uid);
    return data?["role"] as String?;
  }

  // Updates a user's name and phone number, for the edit profile screen.
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    await _firestoreService.updateDocument(_usersCollection, uid, {
      "name": name,
      "phone": phone,
    });
  }

  // Saves a user's current latitude/longitude, so nearby artisan search can
  // measure distance from it later.
  Future<void> updateMyLocation({
    required String uid,
    required double latitude,
    required double longitude,
  }) async {
    await _firestoreService.updateDocument(_usersCollection, uid, {
      "latitude": latitude,
      "longitude": longitude,
    });
  }

  // Every account, for the admin Manage Users screen, no filtering.
  Future<List<UserModel>> getAllUsers() async {
    final docs = await _firestoreService.getCollectionOrdered(
      _usersCollection,
      orderBy: "name",
    );
    return docs.map(UserModel.fromMap).toList();
  }

  // A single user by uid, for admin screens that only have an id on hand,
  // for example a booking's customerId/artisanId or an application's
  // artisanId, and need to show a name instead.
  Future<UserModel?> getUserById(String uid) async {
    final data = await _firestoreService.getDocument(_usersCollection, uid);
    if (data == null) return null;
    return UserModel.fromMap(data);
  }
}
