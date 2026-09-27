import 'package:firebase_auth/firebase_auth.dart';

/// Centralized authentication service interacting with Firebase Authentication.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _firebaseAuth.setSettings(appVerificationDisabledForTesting: true);
  }

  final FirebaseAuth _firebaseAuth;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Gets the currently authenticated user, or null if none.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Registers a new user with name, email, and password.
  Future<UserCredential> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Update the display name of the newly created user
    if (credential.user != null && name.trim().isNotEmpty) {
      await credential.user!.updateDisplayName(name.trim());
      await credential.user!.reload();
    }

    return credential;
  }

  /// Signs in an existing user with email and password.
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Signs out the currently authenticated user.
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
