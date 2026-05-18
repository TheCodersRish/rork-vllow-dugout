import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';

enum AuthFlowState { onboarding, auth, main }

class AuthViewModel extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = false;
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showError = false;
  bool _shouldSwitchToSignIn = false;
  bool _showResetSent = false;

  late final AuthService _authService;
  StreamSubscription<AuthUser?>? _authSubscription;
  static const _onboardingKey = 'has_completed_onboarding';

  bool get isAuthenticated => _isAuthenticated;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showError => _showError;
  bool get shouldSwitchToSignIn => _shouldSwitchToSignIn;
  bool get showResetSent => _showResetSent;
  bool get isFirebaseEnabled => _authService.isFirebaseEnabled;

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
    if (!_isAuthenticated) return AuthFlowState.auth;
    return AuthFlowState.main;
  }

  final SharedPreferences _prefs;

  AuthViewModel(this._prefs) {
    _authService = AuthService.fromPrefs(_prefs);
    _loadOnboardingFlag();
    _restoreSession();
    _listenToAuthChanges();
  }

  Future<void> init() async {
    await _loadOnboardingFlag();
    await _restoreSession();
  }

  void _listenToAuthChanges() {
    _authSubscription = _authService.authStateChanges().listen((user) {
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
      } else if (_authService.isFirebaseEnabled) {
        _currentUser = null;
        _isAuthenticated = false;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadOnboardingFlag() async {
    _hasCompletedOnboarding = _prefs.getBool(_onboardingKey) ?? false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    notifyListeners();
    await _prefs.setBool(_onboardingKey, true);
  }

  Future<void> signUp(String email, String password, String name) async {
    await _runAuthAction(() async {
      final user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );
      _applySignedInUser(user);
    });
  }

  Future<void> signIn(String email, String password) async {
    await _runAuthAction(() async {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );
      _applySignedInUser(user);
    });
  }

  Future<void> signInWithGoogle() async {
    await _runAuthAction(() async {
      final user = await _authService.signInWithGoogle();
      _applySignedInUser(user);
    });
  }

  Future<void> signInWithApple() async {
    await _runAuthAction(() async {
      final user = await _authService.signInWithApple();
      _applySignedInUser(user);
    });
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      _errorMessage = e.toString();
      _showError = true;
    }
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordReset(email: email);
      _showResetSent = true;
    } catch (e) {
      _errorMessage = _messageFromError(e);
      _showError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _restoreSession() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      _applySignedInUser(user);
    }
  }

  void _applySignedInUser(AuthUser user) {
    _currentUser = user;
    _isAuthenticated = true;
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } on AuthException catch (e) {
      if (e.type == AuthErrorType.cancelled) return;
      if (e.type == AuthErrorType.emailAlreadyExists) {
        _shouldSwitchToSignIn = true;
        _errorMessage = 'Account already exists \u2014 sign in instead';
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
