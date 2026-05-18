import 'dart:async';
import 'dart:convert';

import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

import '../config/clerk_config.dart';
import '../models/auth_user.dart';
import '../utils/clerk_user_mapper.dart';

enum AuthFlowState { onboarding, auth, main }

class AuthViewModel extends ChangeNotifier {
  bool _hasCompletedOnboarding = false;
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showError = false;
  bool _shouldSwitchToSignIn = false;
  bool _showResetSent = false;

  ClerkAuthState? _clerk;
  StreamSubscription<clerk.ClerkError>? _errorSubscription;
  static const _onboardingKey = 'has_completed_onboarding';
  static const _mockSessionKey = 'auth_mock_session_user';

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showError => _showError;
  bool get shouldSwitchToSignIn => _shouldSwitchToSignIn;
  bool get showResetSent => _showResetSent;
  bool get isClerkEnabled => ClerkConfig.isReady;
  bool get isClerkReady => isClerkEnabled && _clerk != null;
  bool get isAuthenticated => _currentUser != null;

  set showError(bool value) {
    _showError = value;
    notifyListeners();
  }

  set shouldSwitchToSignIn(bool value) {
    _shouldSwitchToSignIn = value;
    notifyListeners();
  }

  set showResetSent(bool value) {
    _showResetSent = value;
    notifyListeners();
  }

  AuthFlowState get authState {
    if (!_hasCompletedOnboarding) return AuthFlowState.onboarding;
    if (!isAuthenticated) return AuthFlowState.auth;
    return AuthFlowState.main;
  }

  final SharedPreferences _prefs;

  AuthViewModel(this._prefs) {
    _hasCompletedOnboarding = _prefs.getBool(_onboardingKey) ?? false;
    _restoreMockSession();
  }

  Future<void> init() async {
    _hasCompletedOnboarding = _prefs.getBool(_onboardingKey) ?? false;
    _restoreMockSession();
    notifyListeners();
  }

  void _restoreMockSession() {
    if (ClerkConfig.isReady) return;
    final raw = _prefs.getString(_mockSessionKey);
    if (raw == null) return;
    try {
      _currentUser =
          AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      _prefs.remove(_mockSessionKey);
    }
  }

  /// Call once from a widget under [ClerkAuth] (e.g. [_AppRoot]).
  void bindClerk(BuildContext context) {
    final clerkState = ClerkAuth.of(context, listen: false);
    if (identical(_clerk, clerkState)) return;

    _errorSubscription?.cancel();
    _clerk?.removeListener(_syncFromClerk);

    _clerk = clerkState;
    _clerk!.addListener(_syncFromClerk);
    _errorSubscription = _clerk!.errorStream.listen(_onClerkError);
    _syncFromClerk();
  }

  void unbindClerk() {
    _errorSubscription?.cancel();
    _errorSubscription = null;
    _clerk?.removeListener(_syncFromClerk);
    _clerk = null;
  }

  void _syncFromClerk() {
    final user = _clerk?.user;
    _currentUser = user == null ? null : authUserFromClerk(user);
    notifyListeners();
  }

  void _onClerkError(clerk.ClerkError error) {
    _errorMessage = error.message;
    _showError = true;
    notifyListeners();
  }

  @override
  void dispose() {
    unbindClerk();
    super.dispose();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _prefs.setBool(_onboardingKey, true);
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String name) async {
    if (!ClerkConfig.isReady) {
      await _mockSignUp(email: email, name: name);
      return;
    }

    final clerkState = _requireClerk();
    final parts = name.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : 'Player';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    await _runAuthAction(() async {
      await clerkState.attemptSignUp(
        strategy: clerk.Strategy.password,
        emailAddress: email.trim(),
        password: password,
        firstName: firstName,
        lastName: lastName.isEmpty ? ' ' : lastName,
      );
      _syncFromClerk();
    });
  }

  Future<void> signIn(String email, String password) async {
    if (!ClerkConfig.isReady) {
      await _mockSignIn(email: email);
      return;
    }

    final clerkState = _requireClerk();
    await _runAuthAction(() async {
      await clerkState.attemptSignIn(
        strategy: clerk.Strategy.password,
        identifier: email.trim(),
        password: password,
      );
      _syncFromClerk();
    });
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    if (!ClerkConfig.isReady) {
      _errorMessage =
          'Enable Clerk in lib/config/clerk_config.dart (see CLERK_SETUP.md).';
      _showError = true;
      notifyListeners();
      return;
    }

    if (!ClerkConfig.googleClientId.contains('REPLACE')) {
      await _oauthIdTokenSignIn(
        context: context,
        provider: clerk.IdTokenProvider.google,
        clientId: ClerkConfig.googleClientId,
      );
      return;
    }

    final clerkState = _requireClerk();
    await _runAuthAction(() async {
      await clerkState.ssoSignIn(context, clerk.Strategy.oauthGoogle);
      _syncFromClerk();
    });
  }

  Future<void> signInWithApple(BuildContext context) async {
    if (!ClerkConfig.isReady) {
      _errorMessage =
          'Enable Clerk in lib/config/clerk_config.dart (see CLERK_SETUP.md).';
      _showError = true;
      notifyListeners();
      return;
    }

    final clerkState = _requireClerk();
    if (clerkState.env.config.firstFactors
        .contains(clerk.Strategy.oauthTokenApple)) {
      await _oauthIdTokenSignIn(
        context: context,
        provider: clerk.IdTokenProvider.apple,
      );
      return;
    }

    await _runAuthAction(() async {
      await clerkState.ssoSignIn(context, clerk.Strategy.oauthApple);
      _syncFromClerk();
    });
  }

  Future<void> _oauthIdTokenSignIn({
    required BuildContext context,
    required clerk.IdTokenProvider provider,
    String? clientId,
  }) async {
    final clerkState = _requireClerk();
    await _runAuthAction(() async {
      await clerkState.safelyCall(context, () async {
        String? token;
        String? givenName;
        String? familyName;

        if (provider == clerk.IdTokenProvider.google) {
          final google = GoogleSignIn.instance;
          await clerkState.resetClient();
          await google.initialize(
            serverClientId: clientId,
            nonce: const Uuid().v4(),
          );
          final account = await google.authenticate(
            scopeHint: const ['openid', 'email', 'profile'],
          );
          final nameParts = account.displayName?.split(' ');
          givenName = nameParts?.first ?? 'Player';
          familyName = nameParts != null && nameParts.length > 1
              ? nameParts.sublist(1).join(' ')
              : '';
          token = account.authentication.idToken;
        } else {
          final credential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );
          givenName = credential.givenName ?? 'Player';
          familyName = credential.familyName ?? '';
          token = credential.identityToken;
        }

        if (token == null || token.isEmpty) {
          throw clerk.ClerkError(message: 'Missing identity token');
        }

        await clerkState.idTokenSignIn(provider: provider, token: token);

        if (clerkState.signUp case clerk.SignUp signUp
            when signUp.missingFields.isNotEmpty) {
          await clerkState.attemptSignUp(
            legalAccepted:
                signUp.missing(clerk.Field.legalAccepted) ? true : null,
            firstName: signUp.missing(clerk.Field.firstName) ? givenName : null,
            lastName: signUp.missing(clerk.Field.lastName) ? familyName : null,
          );
        }
      });
      _syncFromClerk();
    });
  }

  Future<void> signOut() async {
    if (ClerkConfig.isReady) {
      await _clerk?.signOut();
    }
    _currentUser = null;
    await _prefs.remove(_mockSessionKey);
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!ClerkConfig.isReady) {
        await Future.delayed(const Duration(milliseconds: 400));
        _showResetSent = true;
        return;
      }

      final clerkState = _requireClerk();
      await clerkState.initiatePasswordReset(
        identifier: email.trim(),
        strategy: clerk.Strategy.resetPasswordEmailCode,
      );
      _showResetSent = true;
    } catch (e) {
      _errorMessage = _messageFromError(e);
      _showError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ClerkAuthState _requireClerk() {
    if (_clerk == null) {
      throw StateError(
        'Clerk is not bound. Set ClerkConfig.enabled and publishableKey.',
      );
    }
    return _clerk!;
  }

  Future<void> _mockSignUp({
    required String email,
    required String name,
  }) async {
    await _runAuthAction(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      final user = AuthUser(
        id: 'mock_${email.hashCode}',
        email: email,
        name: name,
      );
      _currentUser = user;
      await _prefs.setString(_mockSessionKey, jsonEncode(user.toJson()));
    });
  }

  Future<void> _mockSignIn({required String email}) async {
    await _runAuthAction(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      final user = AuthUser(
        id: 'mock_${email.hashCode}',
        email: email,
        name: email.contains('@') ? email.split('@').first : 'Champion',
      );
      _currentUser = user;
      await _prefs.setString(_mockSessionKey, jsonEncode(user.toJson()));
    });
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } on clerk.ClerkError catch (e) {
      final message = e.message.toLowerCase();
      if (message.contains('already') || message.contains('exists')) {
        _shouldSwitchToSignIn = true;
        _errorMessage = 'Account already exists — sign in instead';
      } else {
        _errorMessage = e.message;
      }
      _showError = true;
    } catch (e) {
      _errorMessage = _messageFromError(e);
      _showError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _messageFromError(Object e) {
    final text = e.toString();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }
    return text;
  }
}
