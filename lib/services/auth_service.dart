import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/constants/app_constants.dart';

const _usernameTaken =
    'That username is already taken. Please try another one.';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void>? _googleInit;

  /// Role chosen on the screen the person used for Google sign-in
  /// ('student' or 'owner'). CompleteProfileScreen reads it for new Google users.
  String _pendingRole = 'student';
  String get pendingRole => _pendingRole;

  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= GoogleSignIn.instance.initialize(
      serverClientId: kGoogleWebClientId,
    );
  }

  Stream<User?> get userChanges => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  // ---------- Username / profile ----------

  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _db
        .collection('usernames')
        .doc(username.toLowerCase())
        .get();
    return !doc.exists;
  }

  Future<bool> hasProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists;
  }

  /// Saved role ('student', 'owner', ...) or null if there is no profile yet.
  Future<String?> getRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return (doc.data()?['role'] as String?) ?? 'student';
  }

  /// Claims the username and creates the profile in ONE atomic batch.
  /// If the username already exists, the whole batch fails.
  Future<void> _createProfile(
    User user, {
    required String name,
    required String username,
    required String email,
  }) {
    final batch = _db.batch();
    batch.set(_db.collection('usernames').doc(username), {'uid': user.uid});
    batch.set(_db.collection('users').doc(user.uid), {
      'uid': user.uid,
      'name': name.trim(),
      'username': username,
      'email': email.trim().toLowerCase(),
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return batch.commit();
  }

  /// Owners have no username: just their profile document.
  Future<void> _createOwnerProfile(
    User user, {
    required String businessName,
    required String phone,
    required String email,
  }) {
    return _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': businessName.trim(),
      'businessName': businessName.trim(),
      'phone': phone.replaceAll(RegExp(r'[\s-]'), ''),
      'email': email.trim().toLowerCase(),
      'role': 'owner',
      'verified': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// For Google users who have no profile yet (students).
  Future<void> completeProfile({required String username}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('You are signed out. Please log in again.');
    }
    final uname = username.trim().toLowerCase();
    try {
      if (!await isUsernameAvailable(uname)) {
        throw const AuthException(_usernameTaken);
      }
      await _createProfile(
        user,
        name: user.displayName ?? '',
        username: uname,
        email: user.email ?? '',
      );
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthException(_usernameTaken);
      }
      throw const AuthException(
        'Could not save your profile. Check your connection and retry.',
      );
    }
  }

  /// For Google users who signed in from an owner screen and have no profile yet.
  Future<void> completeOwnerProfile({
    required String businessName,
    required String phone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('You are signed out. Please log in again.');
    }
    try {
      await _createOwnerProfile(
        user,
        businessName: businessName,
        phone: phone,
        email: user.email ?? '',
      );
    } on FirebaseException {
      throw const AuthException(
        'Could not save your profile. Check your connection and retry.',
      );
    }
  }

  // ---------- Email / password ----------

  Future<void> signUpWithEmail({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final uname = username.trim().toLowerCase();
    try {
      if (!await isUsernameAvailable(uname)) {
        throw const AuthException(_usernameTaken);
      }
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;

      try {
        await _createProfile(user, name: name, username: uname, email: email);
      } on FirebaseException catch (e) {
        await user.delete(); // roll back so no half-made account remains
        throw AuthException(
          e.code == 'permission-denied'
              ? _usernameTaken
              : 'Could not save your profile. Please try again.',
        );
      }

      await user.updateDisplayName(name.trim());
      try {
        await user.sendEmailVerification();
      } catch (e) {
        // The verify screen has a Resend button, so don't fail sign-up.
        debugPrint('Could not send verification email: $e');
      }
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } on FirebaseException {
      throw const AuthException(
        'Could not reach the server. Check your connection and try again.',
      );
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  Future<void> signUpOwnerWithEmail({
    required String businessName,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;

      try {
        await _createOwnerProfile(
          user,
          businessName: businessName,
          phone: phone,
          email: email,
        );
      } on FirebaseException {
        await user.delete(); // roll back so no half-made account remains
        throw const AuthException(
          'Could not save your profile. Please try again.',
        );
      }

      await user.updateDisplayName(businessName.trim());
      try {
        await user.sendEmailVerification();
      } catch (e) {
        debugPrint('Could not send verification email: $e');
      }
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } on FirebaseException {
      throw const AuthException(
        'Could not reach the server. Check your connection and try again.',
      );
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  // ---------- Email verification ----------

  Future<void> sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  Future<bool> reloadAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Used by "Wrong email? Start over": removes profile, frees the username
  /// (students only), then deletes the auth account.
  Future<void> deleteCurrentAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final profile = await _db.collection('users').doc(user.uid).get();
      final username = profile.data()?['username'] as String?;
      final batch = _db.batch();
      if (username != null) {
        batch.delete(_db.collection('usernames').doc(username));
      }
      batch.delete(_db.collection('users').doc(user.uid));
      await batch.commit();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } on FirebaseException {
      throw const AuthException(
        'Could not delete the account. Please try again.',
      );
    }
  }

  // ---------- Google ----------

  /// [role] is 'student' (default) or 'owner'; it only matters for new users.
  /// Returns null if the user cancelled the Google dialog.
  Future<UserCredential?> signInWithGoogle({String role = 'student'}) async {
    _pendingRole = role;
    try {
      await _ensureGoogleInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Google sign-in failed. Please try again.');
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await _auth.signInWithCredential(credential);
    } on AuthException {
      rethrow;
    } on GoogleSignInException catch (e) {
      debugPrint('Google sign-in error: $e');
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw AuthException('Google sign-in failed (${e.code.name}).');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } catch (e, st) {
      debugPrint('Unexpected Google sign-in error: $e\n$st');
      throw const AuthException('Google sign-in failed. Please try again.');
    }
  }

  Future<void> signOut() async {
    if (_googleInit != null) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in instead.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'weak-password':
        return 'Password is too weak. Choose a stronger one.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a bit and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and retry.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase.';
      case 'requires-recent-login':
        return 'Please log in again and retry.';
      default:
        return 'Authentication failed (${e.code}). Please try again.';
    }
  }
}
