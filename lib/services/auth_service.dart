import 'package:firebase_auth/firebase_auth.dart';

// The only class that talks to Firebase Authentication directly. It does
// not know about Firestore, UserModel, or any app-specific rule, that lives
// in lib/repositories/auth_repository.dart, which calls this class.
//
// register() and login() catch FirebaseAuthException and rethrow a plain
// Exception with the same message. This means every caller, repositories,
// providers, and screens, only ever needs to catch a normal Exception and
// never needs to import firebase_auth. Only files under lib/services/
// should import firebase_auth or cloud_firestore.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Registration failed");
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
