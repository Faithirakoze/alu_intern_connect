import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Watch auth state changes (logged in or not)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // REGISTER
  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    required String role, // 'student' or 'startup'
  }) async {
    try {
      // Create account in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save extra info to Firestore
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'fullName': fullName,
        'email': email,
        'role': role,
        'createdAt': Timestamp.now(),
      });

      return null; // null means success
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // LOGIN
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // null means success
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Turn Firebase error codes into readable messages
  String _errorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}