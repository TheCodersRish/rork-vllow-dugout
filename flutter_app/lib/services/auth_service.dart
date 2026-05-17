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
  AuthUser? _currentUser;

  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = AuthUser(email: email, name: name);
    return _currentUser!;
  }

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = AuthUser(email: email, name: email.split('@').first);
    return _currentUser!;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  Future<void> sendPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<AuthUser?> getCurrentUser() async {
    return _currentUser;
  }
}
