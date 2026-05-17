import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';

enum AuthErrorType {
  emailAlreadyExists,
  invalidCredentials,
  networkError,
  unknown,
}

class AuthException implements Exception {
  final String message;
  final AuthErrorType type;
  AuthException(this.message, this.type);

  @override
  String toString() => message;
}

class AuthService {
  static const _currentUserKey = 'auth_current_user';

  final SharedPreferences? _prefs;
  AuthUser? _currentUser;

  AuthService([this._prefs]);

  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = AuthUser(email: email, name: name);
    await _persistCurrentUser();
    return _currentUser!;
  }

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = AuthUser(email: email, name: email.split('@').first);
    await _persistCurrentUser();
    return _currentUser!;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    await _prefs?.remove(_currentUserKey);
  }

  Future<void> sendPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<AuthUser?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final userJson = _prefs?.getString(_currentUserKey);
    if (userJson == null) return null;

    try {
      final decoded = jsonDecode(userJson) as Map<String, dynamic>;
      _currentUser = AuthUser.fromJson(decoded);
    } catch (_) {
      await _prefs?.remove(_currentUserKey);
    }

    return _currentUser;
  }

  Future<void> _persistCurrentUser() async {
    final currentUser = _currentUser;
    if (currentUser == null) return;

    await _prefs?.setString(_currentUserKey, jsonEncode(currentUser.toJson()));
  }
}
