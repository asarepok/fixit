import 'package:firebase_auth/firebase_auth.dart';

// The only class that talks to Firebase Authentication directly. It does
// not know about Firestore, UserModel, or any app-specific rule, that lives
// in lib/repositories/auth_repository.dart, which calls this class.
//
// register() and login() turn FirebaseAuthException into safe, plain
// Exception messages. Authentication failures do not reveal whether an
// account or email address exists, and screens never import firebase_auth.
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
      throw Exception(_messageFor(e, isRegistration: true));
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
      throw Exception(_messageFor(e));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _messageFor(
    FirebaseAuthException error, {
    bool isRegistration = false,
  }) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'Unable to create an account with these details.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      default:
        return isRegistration
            ? 'Unable to create an account. Please try again.'
            : 'Unable to sign in. Please try again.';
    }
  }
}
