import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/drill.dart';
import '../models/leaderboard_entry.dart';
import '../models/performance_stats.dart';
import '../utils/mock_data.dart';

class CoinTransaction {
  final int amount;
  final String reason;
  final DateTime date;
  CoinTransaction({required this.amount, required this.reason, DateTime? date})
      : date = date ?? DateTime.now();

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      amount: json['amount'] as int,
      reason: json['reason'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'reason': reason,
      'date': date.toIso8601String(),
    };
  }
}

class GameDataService {
  final SharedPreferences? _prefs;

  int _vCoins;
  final int _winStreak;
  final int _globalRank;
  int _drillsCompleted;
  final Set<String> _bookmarkedDrills = {};
  final Set<String> _completedDrills = {};
  final List<CoinTransaction> _recentCoins = [];
  final List<PerformanceStats> _recordedMatches = [];

  static const _vCoinsKey = 'v_coins';
  static const _winStreakKey = 'win_streak';
  static const _rankKey = 'global_rank';
  static const _drillsKey = 'drills_completed';
  static const _bookmarkedDrillsKey = 'bookmarked_drills';
  static const _completedDrillsKey = 'completed_drills';
  static const _recentCoinsKey = 'recent_coin_transactions';
  static const _recordedMatchesKey = 'recorded_matches';

  int get vCoins => _vCoins;
  int get winStreak => _winStreak;
  int get globalRank => _globalRank;
  int get drillsCompleted => _drillsCompleted;

  List<Drill> get drills => MockData.drills;
  List<CoinTransaction> get recentCoinTransactions => _recentCoins;
  List<PerformanceStats> get matchHistory => [
        ..._recordedMatches,
        ...MockData.matchHistory,
      ];
  List<ScoringZone> get scoringZones => MockData.scoringZones;
  List<DismissalPattern> get dismissalPatterns => MockData.dismissalPatterns;

  List<LeaderboardEntry> leaderboard(dynamic period) => MockData.leaderboard;

  bool isDrillCompleted(String id) => _completedDrills.contains(id);

  GameDataService({SharedPreferences? prefs})
      : _prefs = prefs,
        _vCoins = prefs?.getInt(_vCoinsKey) ?? 1250,
        _winStreak = prefs?.getInt(_winStreakKey) ?? 12,
        _globalRank = prefs?.getInt(_rankKey) ?? 422,
        _drillsCompleted = prefs?.getInt(_drillsKey) ?? 87 {
    _loadPersistedCollections();
  }

  void earnCoins(int amount, {String reason = ''}) {
    _vCoins += amount;
    _recentCoins.insert(0, CoinTransaction(amount: amount, reason: reason));
    if (_recentCoins.length > 20) _recentCoins.removeLast();
    _prefs?.setInt(_vCoinsKey, _vCoins);
    _persistCoinTransactions();
  }

  void spendCoins(int amount) {
    _vCoins = (_vCoins - amount).clamp(0, 999999).toInt();
    _prefs?.setInt(_vCoinsKey, _vCoins);
  }

  bool completeDrill(String id) {
    if (_completedDrills.contains(id)) return false;

    _completedDrills.add(id);
    _drillsCompleted++;
    _prefs?.setInt(_drillsKey, _drillsCompleted);
    _prefs?.setStringList(_completedDrillsKey, _completedDrills.toList());
    return true;
  }

  void toggleBookmark(String drillId) {
    if (_bookmarkedDrills.contains(drillId)) {
      _bookmarkedDrills.remove(drillId);
    } else {
      _bookmarkedDrills.add(drillId);
    }
    _prefs?.setStringList(_bookmarkedDrillsKey, _bookmarkedDrills.toList());
  }

  bool isBookmarked(String drillId) => _bookmarkedDrills.contains(drillId);

  void addMatch(PerformanceStats stats) {
    _recordedMatches.insert(0, stats);
    if (_recordedMatches.length > 25) _recordedMatches.removeLast();
    _prefs?.setString(
      _recordedMatchesKey,
      jsonEncode(_recordedMatches.map((match) => match.toJson()).toList()),
    );
  }

  void _loadPersistedCollections() {
    _bookmarkedDrills.addAll(_prefs?.getStringList(_bookmarkedDrillsKey) ?? []);
    _completedDrills.addAll(_prefs?.getStringList(_completedDrillsKey) ?? []);

    final recentCoinsJson = _prefs?.getString(_recentCoinsKey);
    if (recentCoinsJson != null) {
      try {
        final recentCoins = jsonDecode(recentCoinsJson) as List<dynamic>;
        _recentCoins
          ..clear()
          ..addAll(recentCoins
              .map((item) => CoinTransaction.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .take(20));
      } catch (_) {
        _prefs?.remove(_recentCoinsKey);
      }
    }

    final recordedMatchesJson = _prefs?.getString(_recordedMatchesKey);
    if (recordedMatchesJson != null) {
      try {
        final recordedMatches =
            jsonDecode(recordedMatchesJson) as List<dynamic>;
        _recordedMatches
          ..clear()
          ..addAll(recordedMatches.map((item) => PerformanceStats.fromJson(
                Map<String, dynamic>.from(item as Map),
              )));
      } catch (_) {
        _prefs?.remove(_recordedMatchesKey);
      }
    }
  }

  void _persistCoinTransactions() {
    _prefs?.setString(
      _recentCoinsKey,
      jsonEncode(_recentCoins.map((tx) => tx.toJson()).toList()),
    );
  }
}
