import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_plan.dart';
import '../models/meal_profile.dart';
import '../services/ai_meal_service.dart';

class MealPlanViewModel extends ChangeNotifier {
  final SharedPreferences _prefs;
  MealPlan? _currentPlan;
  MealProfile? _mealProfile;
  List<MealPlan> _savedPlans = [];
  bool _isLoading = false;
  bool _hasShownInitialQuestionnaire = false;

  static const _profileKey = 'meal_profile';
  static const _savedPlansKey = 'saved_meal_plans';
  static const _shownQuestionnaireKey = 'shown_meal_questionnaire';

  MealPlan? get currentPlan => _currentPlan;
  MealProfile? get mealProfile => _mealProfile;
  List<MealPlan> get savedPlans => _savedPlans;
  bool get isLoading => _isLoading;
  bool get hasProfile => _mealProfile != null;
  bool get shouldShowQuestionnaire =>
      !_hasShownInitialQuestionnaire && _mealProfile == null;

  MealPlanViewModel(this._prefs) {
    _loadProfile();
    _loadSavedPlans();
    _hasShownInitialQuestionnaire =
        _prefs.getBool(_shownQuestionnaireKey) ?? false;
  }

  void _loadProfile() {
    final json = _prefs.getString(_profileKey);
    if (json != null) {
      _mealProfile = MealProfile.fromJson(jsonDecode(json));
    }
  }

  void _loadSavedPlans() {
    final json = _prefs.getString(_savedPlansKey);
    if (json != null) {
      final list = jsonDecode(json) as List;
      _savedPlans = list.map((e) => MealPlan.fromJson(e)).toList();
    }
  }

  void markQuestionnaireShown() {
    _hasShownInitialQuestionnaire = true;
    _prefs.setBool(_shownQuestionnaireKey, true);
    notifyListeners();
  }

  void saveMealProfile(MealProfile profile) {
    _mealProfile = profile;
    _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    markQuestionnaireShown();
    notifyListeners();
  }

  Future<void> generatePlan(MealGoal goal, DietPreference diet) async {
    _isLoading = true;
    notifyListeners();

    try {
      final plan = await AiMealService.generatePlan(
        goal: goal,
        diet: diet,
        profile: _mealProfile,
      );

      _currentPlan = plan;
      _savedPlans.insert(0, plan);
      if (_savedPlans.length > 10) {
        _savedPlans = _savedPlans.sublist(0, 10);
      }
      _prefs.setString(
          _savedPlansKey,
          jsonEncode(_savedPlans.map((p) => p.toJson()).toList()));
    } catch (e) {
      debugPrint('Error generating plan: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void loadPlan(MealPlan plan) {
    _currentPlan = plan;
    notifyListeners();
  }
}
