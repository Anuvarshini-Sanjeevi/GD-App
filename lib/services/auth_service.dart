import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gdapp/main.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    if (!isFirebaseInitialized) {
      debugPrint("Google Sign-In: Firebase not initialized. Please add configuration files.");
      return null;
    }
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (!isFirebaseInitialized) return;
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  // Get current user
  User? get currentUser => isFirebaseInitialized ? _auth.currentUser : null;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => isFirebaseInitialized 
      ? _auth.authStateChanges() 
      : const Stream.empty();
}
