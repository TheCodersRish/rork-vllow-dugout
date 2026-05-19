import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kinde_flutter_sdk/kinde_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/kinde_config.dart';
import '../models/auth_user.dart';
import '../utils/kinde_user_mapper.dart';

enum AuthFlowState { onboarding, auth, main }

class AuthViewModel extends ChangeNotifier {
  bool _hasCompletedOnboarding = false;
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showError = false;
  bool _shouldSwitchToSignIn = false;
  bool _showResetSent = false;

  static const _onboardingKey = 'has_completed_onboarding';
  static const _mockSessionKey = 'auth_mock_session_user';

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showError => _showError;
  bool get shouldSwitchToSignIn => _shouldSwitchToSignIn;
  bool get showResetSent => _showResetSent;
  bool get isKindeEnabled => KindeConfig.isReady;
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
    if (KindeConfig.isReady) {
      await _syncFromKinde();
    } else {
      _restoreMockSession();
    }
    notifyListeners();
  }

  void _restoreMockSession() {
    if (KindeConfig.isReady) return;
    final raw = _prefs.getString(_mockSessionKey);
    if (raw == null) return;
    try {
      _currentUser =
          AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      _prefs.remove(_mockSessionKey);
    }
  }

  Future<void> _syncFromKinde() async {
    final sdk = KindeFlutterSDK.instance;
    if (!await sdk.isAuthenticated()) {
      _currentUser = null;
      return;
    }
    final profile = await sdk.getUserProfileV2();
    _currentUser = profile == null ? null : authUserFromKinde(profile);
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _prefs.setBool(_onboardingKey, true);
    notifyListeners();
  }

  /// Opens Kinde hosted sign-in (email, Google, Apple per dashboard).
  Future<void> signInWithKinde() async {
    if (!KindeConfig.isReady) {
      _errorMessage =
          'Enable Kinde in lib/config/kinde_config.dart (see KINDE_SETUP.md).';
      _showError = true;
      notifyListeners();
      return;
    }

    await _runAuthAction(() async {
      await KindeFlutterSDK.instance.login(type: AuthFlowType.pkce);
      await _syncFromKinde();
    });
  }

  /// Opens Kinde hosted registration.
  Future<void> registerWithKinde() async {
    if (!KindeConfig.isReady) {
      _errorMessage =
          'Enable Kinde in lib/config/kinde_config.dart (see KINDE_SETUP.md).';
      _showError = true;
      notifyListeners();
      return;
    }

    await _runAuthAction(() async {
      await KindeFlutterSDK.instance.register(type: AuthFlowType.pkce);
      await _syncFromKinde();
    });
  }

  Future<void> signUp(String email, String password, String name) async {
    if (KindeConfig.isReady) {
      await registerWithKinde();
      return;
    }
    await _mockSignUp(email: email, name: name);
  }

  Future<void> signIn(String email, String password) async {
    if (KindeConfig.isReady) {
      await signInWithKinde();
      return;
    }
    await _mockSignIn(email: email);
  }

  Future<void> signOut() async {
    if (KindeConfig.isReady) {
      await KindeFlutterSDK.instance.logout();
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
      if (KindeConfig.isReady) {
        _errorMessage =
            'Use “Forgot password?” on the Kinde sign-in page after tapping Sign In.';
        _showError = true;
        return;
      }

      await Future.delayed(const Duration(milliseconds: 400));
      _showResetSent = true;
    } catch (e) {
      _errorMessage = _messageFromError(e);
      _showError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    } on KindeError catch (e) {
      final message = e.message.toLowerCase();
      if (message.contains('cancel')) {
        return;
      }
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
