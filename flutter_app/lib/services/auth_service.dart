import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../firebase_options.dart';
import '../models/auth_user.dart';

enum AuthErrorType {
  emailAlreadyExists,
  invalidCredentials,
  weakPassword,
  userNotFound,
  networkError,
  cancelled,
  unknown,
}

class AuthException implements Exception {
  final String message;
  final AuthErrorType type;
  AuthException(this.message, this.type);

  @override
  String toString() => message;
}

/// Email/password, Google, and Apple via Firebase Auth when configured;
/// falls back to a local mock only when Firebase is not initialized (tests).
class AuthService {
  static const _displayNamesKey = 'auth_display_names';
  static const _mockSessionKey = 'auth_mock_session_user';

  final SharedPreferences? _prefs;
  final FirebaseAuth? _firebaseAuth;
  final GoogleSignIn? _googleSignIn;
  final bool _useFirebase;
  AuthUser? _mockSessionUser;

  AuthService(
    this._prefs, {
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    bool? useFirebase,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _useFirebase = useFirebase ?? DefaultFirebaseOptions.isConfigured;

  factory AuthService.fromPrefs(SharedPreferences prefs) {
    return AuthService(
      prefs,
      firebaseAuth: DefaultFirebaseOptions.isConfigured
          ? FirebaseAuth.instance
          : null,
      googleSignIn: DefaultFirebaseOptions.isConfigured
          ? GoogleSignIn()
          : null,
    );
  }

  bool get isFirebaseEnabled => _useFirebase && _firebaseAuth != null;

  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!_useFirebase) return _mockSignUp(email: email, name: name);

    try {
      final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      final user = _mapFirebaseUser(credential.user!, fallbackName: name);
      await _saveDisplayName(user.id, name);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    if (!_useFirebase) {
      return _mockSignIn(email: email);
    }

    try {
      final credential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<AuthUser> signInWithGoogle() async {
    if (!_useFirebase || _googleSignIn == null) {
      throw AuthException(
        'Google sign-in requires Firebase configuration. See AUTH_SETUP.md.',
        AuthErrorType.unknown,
      );
    }

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Sign-in cancelled', AuthErrorType.cancelled);
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth!.signInWithCredential(credential);
      final user = _mapFirebaseUser(result.user!);
      if (user.name.isNotEmpty) {
        await _saveDisplayName(user.id, user.name);
      }
      return user;
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<AuthUser> signInWithApple() async {
    if (!_useFirebase) {
      throw AuthException(
        'Paste Firebase keys in lib/config/firebase_config.dart and set enabled = true.',
        AuthErrorType.unknown,
      );
    }

    if (kIsWeb) {
      throw AuthException(
        'Apple sign-in is not supported on web in this build.',
        AuthErrorType.unknown,
      );
    }

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final result = await _firebaseAuth!.signInWithCredential(oauthCredential);

      final given = appleCredential.givenName ?? '';
      final family = appleCredential.familyName ?? '';
      final composedName = '$given $family'.trim();
      if (composedName.isNotEmpty) {
        await result.user?.updateDisplayName(composedName);
        await _saveDisplayName(result.user!.uid, composedName);
      }

      return _mapFirebaseUser(
        result.user!,
        fallbackName: composedName.isEmpty ? null : composedName,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AuthException('Sign-in cancelled', AuthErrorType.cancelled);
      }
      throw AuthException(e.message, AuthErrorType.unknown);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<void> signOut() async {
    if (_useFirebase) {
      await _googleSignIn?.signOut();
      await _firebaseAuth?.signOut();
      return;
    }
    _mockSessionUser = null;
    await _prefs?.remove(_mockSessionKey);
  }

  Future<void> sendPasswordReset({required String email}) async {
    if (!_useFirebase) {
      await Future.delayed(const Duration(milliseconds: 400));
      return;
    }

    try {
      await _firebaseAuth!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<AuthUser?> getCurrentUser() async {
    if (_useFirebase) {
      final firebaseUser = _firebaseAuth?.currentUser;
      if (firebaseUser == null) return null;
      return _mapFirebaseUser(firebaseUser);
    }

    if (_mockSessionUser != null) return _mockSessionUser;

    final userJson = _prefs?.getString(_mockSessionKey);
    if (userJson == null) return null;

    try {
      _mockSessionUser =
          AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      await _prefs?.remove(_mockSessionKey);
    }
    return _mockSessionUser;
  }

  Stream<AuthUser?> authStateChanges() {
    if (!_useFirebase || _firebaseAuth == null) {
      return const Stream.empty();
    }
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapFirebaseUser(user);
    });
  }

  AuthUser _mapFirebaseUser(User user, {String? fallbackName}) {
    final id = user.uid;
    final email = user.email ?? '';
    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (_loadDisplayName(id) ??
            fallbackName ??
            (email.contains('@') ? email.split('@').first : 'Champion'));

    return AuthUser(
      id: id,
      email: email,
      name: name,
      avatarURL: user.photoURL,
    );
  }

  Future<AuthUser> _mockSignUp({
    required String email,
    required String name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = 'mock_${email.hashCode}';
    final user = AuthUser(id: id, email: email, name: name);
    await _saveDisplayName(id, name);
    await _persistMockSession(user);
    return user;
  }

  Future<AuthUser> _mockSignIn({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = 'mock_${email.hashCode}';
    final user = AuthUser(
      id: id,
      email: email,
      name: _loadDisplayName(id) ?? email.split('@').first,
    );
    await _persistMockSession(user);
    return user;
  }

  Future<void> _persistMockSession(AuthUser user) async {
    _mockSessionUser = user;
    await _prefs?.setString(_mockSessionKey, jsonEncode(user.toJson()));
  }

  Future<void> _saveDisplayName(String userId, String name) async {
    final dict = _displayNameMap();
    dict[userId] = name;
    await _prefs?.setString(_displayNamesKey, jsonEncode(dict));
  }

  String? _loadDisplayName(String userId) {
    return _displayNameMap()[userId];
  }

  Map<String, String> _displayNameMap() {
    final raw = _prefs?.getString(_displayNamesKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return {};
    }
  }

  AuthException _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AuthException(
          'An account with this email already exists',
          AuthErrorType.emailAlreadyExists,
        );
      case 'invalid-email':
      case 'wrong-password':
      case 'invalid-credential':
        return AuthException(
          'Invalid email or password',
          AuthErrorType.invalidCredentials,
        );
      case 'weak-password':
        return AuthException(
          'Password must be at least 6 characters',
          AuthErrorType.weakPassword,
        );
      case 'user-not-found':
        return AuthException(
          'No account found with this email',
          AuthErrorType.userNotFound,
        );
      case 'network-request-failed':
        return AuthException(
          'Network error. Check your connection.',
          AuthErrorType.networkError,
        );
      default:
        return AuthException(
          e.message ?? 'Authentication failed',
          AuthErrorType.unknown,
        );
    }
  }
}
