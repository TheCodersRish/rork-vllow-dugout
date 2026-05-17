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
}

class GameDataService {
  final SharedPreferences? _prefs;

  int _vCoins;
  int _winStreak;
  int _globalRank;
  int _drillsCompleted;
  final Set<String> _bookmarkedDrills = {};
  final Set<String> _completedDrills = {};
  final List<CoinTransaction> _recentCoins = [];

  static const _vCoinsKey = 'v_coins';
  static const _winStreakKey = 'win_streak';
  static const _rankKey = 'global_rank';
  static const _drillsKey = 'drills_completed';

  int get vCoins => _vCoins;
  int get winStreak => _winStreak;
  int get globalRank => _globalRank;
  int get drillsCompleted => _drillsCompleted;

  List<Drill> get drills => MockData.drills;
  List<CoinTransaction> get recentCoinTransactions => _recentCoins;
  List<PerformanceStats> get matchHistory => MockData.matchHistory;
  List<ScoringZone> get scoringZones => MockData.scoringZones;
  List<DismissalPattern> get dismissalPatterns => MockData.dismissalPatterns;

  List<LeaderboardEntry> leaderboard(dynamic period) => MockData.leaderboard;

  bool isDrillCompleted(String id) => _completedDrills.contains(id);

  GameDataService({SharedPreferences? prefs})
      : _prefs = prefs,
        _vCoins = prefs?.getInt(_vCoinsKey) ?? 1250,
        _winStreak = prefs?.getInt(_winStreakKey) ?? 12,
        _globalRank = prefs?.getInt(_rankKey) ?? 422,
        _drillsCompleted = prefs?.getInt(_drillsKey) ?? 87;

  void earnCoins(int amount, {String reason = ''}) {
    _vCoins += amount;
    _recentCoins.insert(0, CoinTransaction(amount: amount, reason: reason));
    if (_recentCoins.length > 20) _recentCoins.removeLast();
    _prefs?.setInt(_vCoinsKey, _vCoins);
  }

  void spendCoins(int amount) {
    _vCoins = (_vCoins - amount).clamp(0, 999999);
    _prefs?.setInt(_vCoinsKey, _vCoins);
  }

  void completeDrill(String id) {
    _completedDrills.add(id);
    _drillsCompleted++;
    _prefs?.setInt(_drillsKey, _drillsCompleted);
  }

  void toggleBookmark(String drillId) {
    if (_bookmarkedDrills.contains(drillId)) {
      _bookmarkedDrills.remove(drillId);
    } else {
      _bookmarkedDrills.add(drillId);
    }
  }

  bool isBookmarked(String drillId) => _bookmarkedDrills.contains(drillId);
}
