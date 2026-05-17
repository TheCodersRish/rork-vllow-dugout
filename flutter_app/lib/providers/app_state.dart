import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drill.dart';
import '../models/performance_stats.dart';
import '../services/game_data_service.dart';

enum AppTab {
  feed(title: 'Feed', icon: Icons.dynamic_feed),
  coach(title: 'Coach', icon: Icons.psychology),
  meals(title: 'Meals', icon: Icons.restaurant),
  intel(title: 'Intel', icon: Icons.bar_chart),
  arena(title: 'Arena', icon: Icons.emoji_events),
  store(title: 'Store', icon: Icons.shopping_bag);

  final String title;
  final IconData icon;
  const AppTab({required this.title, required this.icon});
}

class AppState extends ChangeNotifier {
  AppTab _selectedTab = AppTab.feed;
  late GameDataService _gameData;
  bool _showCoinEarned = false;
  String _lastCoinReason = '';
  Timer? _coinFeedbackTimer;

  AppTab get selectedTab => _selectedTab;
  GameDataService get gameData => _gameData;
  bool get showCoinEarned => _showCoinEarned;
  String get lastCoinReason => _lastCoinReason;

  int get vCoins => _gameData.vCoins;
  int get winStreak => _gameData.winStreak;
  int get globalRank => _gameData.globalRank;
  int get drillsCompleted => _gameData.drillsCompleted;

  AppState() {
    _gameData = GameDataService();
  }

  Future<void> init([SharedPreferences? prefs]) async {
    prefs ??= await SharedPreferences.getInstance();
    _gameData = GameDataService(prefs: prefs);
    notifyListeners();
  }

  set selectedTab(AppTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  void toggleBookmark(String drillId) {
    _gameData.toggleBookmark(drillId);
    notifyListeners();
  }

  bool isBookmarked(String drillId) {
    return _gameData.isBookmarked(drillId);
  }

  bool completeDrill(Drill drill) {
    final didComplete = _gameData.completeDrill(drill.id);
    if (didComplete) {
      earnCoinsWithFeedback(drill.coinReward, 'Drill completed');
    } else {
      notifyListeners();
    }
    return didComplete;
  }

  void recordMatch(PerformanceStats stats) {
    _gameData.addMatch(stats);
    earnCoinsWithFeedback(stats.coinBonus, 'Match recorded');
  }

  void earnCoinsWithFeedback(int amount, String reason) {
    _gameData.earnCoins(amount, reason: reason);
    _lastCoinReason = '+$amount V-Coins: $reason';
    _showCoinEarned = true;
    notifyListeners();

    _coinFeedbackTimer?.cancel();
    _coinFeedbackTimer = Timer(const Duration(milliseconds: 2500), () {
      _showCoinEarned = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _coinFeedbackTimer?.cancel();
    super.dispose();
  }
}
