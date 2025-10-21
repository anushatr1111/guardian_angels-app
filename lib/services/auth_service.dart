import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Get an instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // You can handle specific errors here, like 'user-not-found', 'wrong-password', etc.
      print('Firebase Auth Exception: ${e.message}');
      return null;
    } catch (e) {
      print('An unexpected error occurred: ${e.toString()}');
      return null;
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Handle errors like 'email-already-in-use', 'weak-password', etc.
      print('Firebase Auth Exception: ${e.message}');
      return null;
    } catch (e) {
      print('An unexpected error occurred: ${e.toString()}');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Error signing out: ${e.toString()}');
    }
  }

  // Auth state stream (to check if user is logged in)
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}