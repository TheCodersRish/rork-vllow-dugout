import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_profile.dart';

class PlayerProfileViewModel extends ChangeNotifier {
  static const _profileKey = 'player_profile';

  final SharedPreferences _prefs;
  PlayerProfile _profile;

  PlayerProfileViewModel(this._prefs)
      : _profile = _loadProfileFromPrefs(_prefs);

  PlayerProfile get profile => _profile;

  bool get isYouthMode => _profile.isYouthMode;

  void updateProfile(PlayerProfile profile) {
    _profile = profile;
    _persist();
    notifyListeners();
  }

  void updateDateOfBirth(DateTime dateOfBirth) {
    updateProfile(_profile.copyWith(dateOfBirth: dateOfBirth));
  }

  void updatePosition(PlayerPosition position) {
    updateProfile(_profile.copyWith(position: position));
  }

  void updateExperienceLevel(ExperienceLevel experienceLevel) {
    updateProfile(_profile.copyWith(experienceLevel: experienceLevel));
  }

  void updateGoals(String goals) {
    updateProfile(_profile.copyWith(goals: goals.trim()));
  }

  void toggleAvailability(String day) {
    final days = _profile.weeklyAvailability.toSet();
    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
    }
    updateProfile(_profile.copyWith(weeklyAvailability: days.toList()..sort()));
  }

  void updateParentConsent({
    required String? parentEmail,
    required bool granted,
  }) {
    updateProfile(
      _profile.copyWith(
        parentEmail:
            parentEmail?.trim().isEmpty ?? true ? null : parentEmail!.trim(),
        parentConsentGranted: granted,
      ),
    );
  }

  void _persist() {
    _prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
  }

  static PlayerProfile _loadProfileFromPrefs(SharedPreferences prefs) {
    final json = prefs.getString(_profileKey);
    if (json == null) return const PlayerProfile();

    try {
      return PlayerProfile.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      prefs.remove(_profileKey);
      return const PlayerProfile();
    }
  }
}
