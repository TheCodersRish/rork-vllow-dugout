import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_modules.dart';

class LocalModulesViewModel extends ChangeNotifier {
  static const _mentalCheckInsKey = 'mental_check_ins';
  static const _journalEntriesKey = 'mental_journal_entries';
  static const _conditioningLogsKey = 'conditioning_logs';
  static const _hydrationKey = 'hydration_glasses';
  static const _mealLogsKey = 'meal_logs';
  static const _videoItemsKey = 'video_analysis_items';
  static const _coachRequestsKey = 'coach_review_requests';
  static const _communityPostsKey = 'community_posts';
  static const _shareDraftsKey = 'share_card_drafts';
  static const _tierKey = 'subscription_tier';
  static const _trialStartKey = 'trial_start';
  static const _dailyRewardDateKey = 'daily_reward_date';
  static const _dailyRewardTotalKey = 'daily_reward_total';

  final SharedPreferences _prefs;

  List<MentalCheckIn> _mentalCheckIns = [];
  List<JournalEntry> _journalEntries = [];
  List<ConditioningLog> _conditioningLogs = [];
  int _hydrationGlasses = 0;
  List<MealLog> _mealLogs = [];
  List<VideoAnalysisItem> _videoItems = [];
  List<CoachReviewRequest> _coachReviewRequests = [];
  List<CommunityPost> _communityPosts = [];
  List<ShareCardDraft> _shareDrafts = [];
  SubscriptionTier _selectedTier = SubscriptionTier.rookie;
  late DateTime _trialStart;
  String _dailyRewardDate = '';
  int _dailyRewardTotal = 0;

  LocalModulesViewModel(this._prefs) {
    _load();
  }

  List<MentalCheckIn> get mentalCheckIns => List.unmodifiable(_mentalCheckIns);
  List<JournalEntry> get journalEntries => List.unmodifiable(_journalEntries);
  List<ConditioningLog> get conditioningLogs =>
      List.unmodifiable(_conditioningLogs);
  int get hydrationGlasses => _hydrationGlasses;
  List<MealLog> get mealLogs => List.unmodifiable(_mealLogs);
  List<VideoAnalysisItem> get videoItems => List.unmodifiable(_videoItems);
  List<CoachReviewRequest> get coachReviewRequests =>
      List.unmodifiable(_coachReviewRequests);
  List<CommunityPost> get communityPosts => List.unmodifiable(_communityPosts);
  List<ShareCardDraft> get shareDrafts => List.unmodifiable(_shareDrafts);
  SubscriptionTier get selectedTier => _selectedTier;
  int get dailyRewardTotal => _dailyRewardTotal;
  int get dailyRewardRemaining => 500 - _dailyRewardTotal;

  MentalCheckIn? get latestCheckIn =>
      _mentalCheckIns.isEmpty ? null : _mentalCheckIns.first;

  int get trialDaysRemaining {
    final elapsed = DateTime.now().difference(_trialStart).inDays;
    return (90 - elapsed).clamp(0, 90).toInt();
  }

  String get mentalInsight {
    final latest = latestCheckIn;
    if (latest == null) {
      return 'Log a mindset check-in to unlock a daily mental performance tip.';
    }
    if (latest.averageScore >= 8) {
      return 'Confidence is high. Use visualization before nets to lock in your best scoring zones.';
    }
    if (latest.focus <= 5) {
      return 'Focus is the limiter today. Try a 4-4-4 breathing reset before your next session.';
    }
    if (latest.confidence <= 5) {
      return 'Confidence needs reps. Pick one controllable skill and finish with three easy wins.';
    }
    return 'Solid mindset baseline. Journal one pressure moment so FR-03 can spot patterns.';
  }

  List<String> get journalThemes {
    final combined = _journalEntries
        .take(6)
        .map((entry) => entry.response.toLowerCase())
        .join(' ');
    final themes = <String>[];
    if (combined.contains('pressure') || combined.contains('nervous')) {
      themes.add('Pressure response');
    }
    if (combined.contains('spin')) themes.add('Spin confidence');
    if (combined.contains('fitness') || combined.contains('tired')) {
      themes.add('Energy management');
    }
    if (combined.contains('shot') || combined.contains('drive')) {
      themes.add('Shot selection');
    }
    return themes.isEmpty ? ['Consistency', 'Positive intent'] : themes;
  }

  int get mentalStreak {
    if (_mentalCheckIns.isEmpty) return 0;
    final uniqueDays = _mentalCheckIns
        .map((checkIn) => _dateStamp(checkIn.createdAt))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    var streak = 0;
    var cursor = DateTime.now();
    for (final day in uniqueDays) {
      if (day == _dateStamp(cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (streak == 0 &&
          day == _dateStamp(cursor.subtract(const Duration(days: 1)))) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 2));
      } else {
        break;
      }
    }
    return streak;
  }

  String get recoveryRecommendation {
    final recentNiggle = _conditioningLogs.any((log) =>
        log.niggleFlagged &&
        DateTime.now().difference(log.createdAt).inDays <= 7);
    final heavyEfforts = _conditioningLogs
        .where((log) =>
            log.effort >= 8 &&
            DateTime.now().difference(log.createdAt).inDays <= 7)
        .length;
    if (recentNiggle) {
      return 'Niggle flagged: switch the next session to mobility and skip max-effort sprint work.';
    }
    if (heavyEfforts >= 3) {
      return 'High load week: add a deload or recovery day before the next match.';
    }
    return 'Load looks manageable. Keep one mobility block after power or bowling work.';
  }

  List<String> get groceryList => [
        'Greek yogurt',
        'Bananas',
        'Brown rice',
        'Chicken or tofu',
        'Electrolyte tablets',
        'Mixed greens',
      ];

  Map<String, String> planForPosition(String position) {
    final lower = position.toLowerCase();
    if (lower.contains('bowler')) {
      return {
        'Power': 'Med-ball slams, split squats, shoulder prehab',
        'Endurance': '6x60m run-up repeats with walk-back recovery',
        'Mobility': 'Thoracic rotation, hip flexor flow, ankle rocks',
        'Movement': 'Bound-to-brace drills and landing control',
      };
    }
    if (lower.contains('wicket')) {
      return {
        'Power': 'Lateral bounds, glute bridge holds, cable chops',
        'Endurance': 'Keeper crouch intervals: 8x45s',
        'Mobility': 'Adductors, ankles, hips, lower back',
        'Movement': 'Side-step takes and leg-side collection patterns',
      };
    }
    return {
      'Power': 'Med-ball throws, jump squats, resisted bat swings',
      'Endurance': 'Shuttle clusters: 5x(20m/40m/60m)',
      'Mobility': 'Hips, hamstrings, thoracic rotation',
      'Movement': 'Crease acceleration + turning mechanics',
    };
  }

  List<Map<String, String>> get recipeCards => const [
        {
          'title': 'Match Eve Rice Bowl',
          'subtitle': 'Brown rice, chicken/tofu, greens, olive oil',
          'callout': 'Slow carbs for tomorrow morning energy',
        },
        {
          'title': 'Hydration Smoothie',
          'subtitle': 'Banana, yogurt, berries, electrolyte pinch',
          'callout': 'Good post-session recovery option',
        },
        {
          'title': 'Power Wrap',
          'subtitle': 'Wholegrain wrap, eggs/paneer, spinach',
          'callout': 'Portable protein before nets',
        },
      ];

  List<Map<String, String>> get coachRoster => const [
        {
          'name': 'Coach Maya',
          'specialty': 'Batting technique',
          'rating': '4.9',
          'bio': 'Former academy batting lead. Great with front-foot balance.',
        },
        {
          'name': 'Coach Arjun',
          'specialty': 'Fast bowling',
          'rating': '4.8',
          'bio': 'Run-up, load-up, and injury-safe pace development.',
        },
        {
          'name': 'Coach Priya',
          'specialty': 'Mental skills',
          'rating': '5.0',
          'bio': 'Pressure routines, confidence plans, and journaling review.',
        },
      ];

  List<Map<String, String>> get addOns => const [
        {
          'name': 'Extra Video Scan',
          'cost': '350 coins',
          'limit': 'Adds one Quick Scan credit',
        },
        {
          'name': 'Pro Report PDF',
          'cost': '900 coins',
          'limit': 'Unlocks export-ready coach report',
        },
        {
          'name': 'Challenge Pass',
          'cost': '250 coins',
          'limit': 'Create one friend challenge',
        },
      ];

  List<String> entitlementLimits(SubscriptionTier tier) {
    return switch (tier) {
      SubscriptionTier.rookie => [
          '5 feed cards/day',
          '2 coach prompts/day',
          '1 video quick scan/month',
          'Community read-only',
        ],
      SubscriptionTier.dugout => [
          'Unlimited drills',
          '25 coach prompts/day',
          '4 video scans/month',
          'Share-card creator',
        ],
      SubscriptionTier.pavilion => [
          'Priority AI analysis',
          'Pro report exports',
          'Expert review discounts',
          'Advanced leaderboards',
        ],
      SubscriptionTier.nextGen => [
          'Youth-safe content',
          'Parent review controls',
          'Age-group leaderboards',
          'Sharing consent gates',
        ],
    };
  }

  List<String> get unlockedBadges {
    final badges = <String>[];
    if (_mentalCheckIns.isNotEmpty) badges.add('Mindset Starter');
    if (_journalEntries.length >= 3) badges.add('Journal Streak');
    if (_conditioningLogs.length >= 3) badges.add('Iron Crease');
    if (_hydrationGlasses >= 8) badges.add('Hydration Pro');
    if (_videoItems.any((item) => item.status == VideoStatus.completed)) {
      badges.add('Video Analyst');
    }
    if (_shareDrafts.isNotEmpty) badges.add('Hype Builder');
    return badges;
  }

  String tierForCoins(int coins) {
    if (coins >= 10000) return 'Diamond Bat';
    if (coins >= 5000) return 'Gold';
    if (coins >= 2000) return 'Silver';
    return 'Bronze';
  }

  int registerReward(int requestedAmount) {
    _resetDailyCapIfNeeded();
    if (_dailyRewardTotal >= 500) return 0;
    final awarded = requestedAmount.clamp(0, 500 - _dailyRewardTotal).toInt();
    _dailyRewardTotal += awarded;
    _prefs.setString(_dailyRewardDateKey, _dailyRewardDate);
    _prefs.setInt(_dailyRewardTotalKey, _dailyRewardTotal);
    notifyListeners();
    return awarded;
  }

  void addMentalCheckIn({
    required int mood,
    required int focus,
    required int confidence,
    String note = '',
  }) {
    _mentalCheckIns.insert(
      0,
      MentalCheckIn(
        mood: mood,
        focus: focus,
        confidence: confidence,
        note: note,
      ),
    );
    _trim(_mentalCheckIns, 30);
    _persistList(_mentalCheckInsKey, _mentalCheckIns);
    notifyListeners();
  }

  void addJournalEntry(String prompt, String response) {
    if (response.trim().isEmpty) return;
    _journalEntries.insert(
      0,
      JournalEntry(prompt: prompt, response: response.trim()),
    );
    _trim(_journalEntries, 30);
    _persistList(_journalEntriesKey, _journalEntries);
    notifyListeners();
  }

  void addConditioningLog({
    required ConditioningCategory category,
    required int effort,
    required bool niggleFlagged,
    String notes = '',
  }) {
    _conditioningLogs.insert(
      0,
      ConditioningLog(
        category: category,
        effort: effort,
        notes: notes,
        niggleFlagged: niggleFlagged,
      ),
    );
    _trim(_conditioningLogs, 30);
    _persistList(_conditioningLogsKey, _conditioningLogs);
    notifyListeners();
  }

  void addHydrationGlass() {
    _hydrationGlasses = (_hydrationGlasses + 1).clamp(0, 12).toInt();
    _prefs.setInt(_hydrationKey, _hydrationGlasses);
    notifyListeners();
  }

  void resetHydration() {
    _hydrationGlasses = 0;
    _prefs.setInt(_hydrationKey, _hydrationGlasses);
    notifyListeners();
  }

  void addMealLog(String title, String context) {
    if (title.trim().isEmpty) return;
    _mealLogs.insert(0, MealLog(title: title.trim(), context: context));
    _trim(_mealLogs, 20);
    _persistList(_mealLogsKey, _mealLogs);
    notifyListeners();
  }

  void addVideo(String title, String tag) {
    _videoItems.insert(
      0,
      VideoAnalysisItem(
        title: title.trim().isEmpty ? 'Net session clip' : title.trim(),
        tag: tag,
        status: VideoStatus.pending,
      ),
    );
    _trim(_videoItems, 20);
    _persistList(_videoItemsKey, _videoItems);
    notifyListeners();
  }

  void advanceVideo(int index) {
    if (index < 0 || index >= _videoItems.length) return;
    final current = _videoItems[index];
    final nextStatus = switch (current.status) {
      VideoStatus.pending => VideoStatus.uploading,
      VideoStatus.uploading => VideoStatus.analyzing,
      VideoStatus.analyzing => VideoStatus.completed,
      VideoStatus.completed => VideoStatus.completed,
    };
    _videoItems[index] = current.copyWith(
      status: nextStatus,
      strengths: nextStatus == VideoStatus.completed
          ? ['Balanced base', 'Strong follow-through', 'Good intent']
          : current.strengths,
      priorities: nextStatus == VideoStatus.completed
          ? ['Play closer to body', 'Earlier head position', 'Repeat tempo']
          : current.priorities,
      drillPrescription: nextStatus == VideoStatus.completed
          ? 'Spin Detection Drill + 20 front-foot shadow reps'
          : current.drillPrescription,
    );
    _persistList(_videoItemsKey, _videoItems);
    notifyListeners();
  }

  void submitCoachReview({
    required String coachName,
    required String tier,
    required String notes,
  }) {
    _coachReviewRequests.insert(
      0,
      CoachReviewRequest(coachName: coachName, tier: tier, notes: notes),
    );
    _trim(_coachReviewRequests, 20);
    _persistList(_coachRequestsKey, _coachReviewRequests);
    notifyListeners();
  }

  void markReviewDelivered(int index) {
    if (index < 0 || index >= _coachReviewRequests.length) return;
    _coachReviewRequests[index] = _coachReviewRequests[index].copyWith(
      delivered: true,
      feedback:
          'Coach notes: improve head stillness, hold finish, and repeat 3x focused drill blocks this week.',
    );
    _persistList(_coachRequestsKey, _coachReviewRequests);
    notifyListeners();
  }

  void addCommunityPost(String body) {
    if (body.trim().isEmpty) return;
    _communityPosts.insert(
      0,
      CommunityPost(author: 'You', body: body.trim()),
    );
    _trim(_communityPosts, 30);
    _persistList(_communityPostsKey, _communityPosts);
    notifyListeners();
  }

  void reactToPost(int index) {
    if (index < 0 || index >= _communityPosts.length) return;
    _communityPosts[index] = _communityPosts[index]
        .copyWith(reactions: _communityPosts[index].reactions + 1);
    _persistList(_communityPostsKey, _communityPosts);
    notifyListeners();
  }

  void commentOnPost(int index) {
    if (index < 0 || index >= _communityPosts.length) return;
    _communityPosts[index] = _communityPosts[index]
        .copyWith(comments: _communityPosts[index].comments + 1);
    _persistList(_communityPostsKey, _communityPosts);
    notifyListeners();
  }

  void reportPost(int index) {
    if (index < 0 || index >= _communityPosts.length) return;
    _communityPosts[index] = _communityPosts[index].copyWith(reported: true);
    _persistList(_communityPostsKey, _communityPosts);
    notifyListeners();
  }

  void blockPostAuthor(int index) {
    if (index < 0 || index >= _communityPosts.length) return;
    _communityPosts[index] = _communityPosts[index].copyWith(blocked: true);
    _persistList(_communityPostsKey, _communityPosts);
    notifyListeners();
  }

  void createShareCard({
    required String format,
    required String caption,
    required bool includeStats,
  }) {
    _shareDrafts.insert(
      0,
      ShareCardDraft(
        format: format,
        caption: caption,
        includeStats: includeStats,
      ),
    );
    _trim(_shareDrafts, 20);
    _persistList(_shareDraftsKey, _shareDrafts);
    notifyListeners();
  }

  void saveShareCard(int index) {
    if (index < 0 || index >= _shareDrafts.length) return;
    _shareDrafts[index] = _shareDrafts[index].copyWith(saved: true);
    _persistList(_shareDraftsKey, _shareDrafts);
    notifyListeners();
  }

  void markShareCardShared(int index) {
    if (index < 0 || index >= _shareDrafts.length) return;
    _shareDrafts[index] = _shareDrafts[index].copyWith(shared: true);
    _persistList(_shareDraftsKey, _shareDrafts);
    notifyListeners();
  }

  void selectTier(SubscriptionTier tier) {
    _selectedTier = tier;
    _prefs.setString(_tierKey, tier.name);
    notifyListeners();
  }

  void _load() {
    _mentalCheckIns = _loadList(
      _mentalCheckInsKey,
      MentalCheckIn.fromJson,
    );
    _journalEntries = _loadList(_journalEntriesKey, JournalEntry.fromJson);
    _conditioningLogs = _loadList(
      _conditioningLogsKey,
      ConditioningLog.fromJson,
    );
    _hydrationGlasses = _prefs.getInt(_hydrationKey) ?? 0;
    _mealLogs = _loadList(_mealLogsKey, MealLog.fromJson);
    _videoItems = _loadList(_videoItemsKey, VideoAnalysisItem.fromJson);
    _coachReviewRequests = _loadList(
      _coachRequestsKey,
      CoachReviewRequest.fromJson,
    );
    _communityPosts = _loadList(_communityPostsKey, CommunityPost.fromJson);
    if (_communityPosts.isEmpty) {
      _communityPosts = [
        CommunityPost(
          author: 'Vllow',
          body: 'Welcome to the club wall. Share wins, not DMs.',
          reactions: 7,
        ),
      ];
    }
    _shareDrafts = _loadList(_shareDraftsKey, ShareCardDraft.fromJson);
    _selectedTier = SubscriptionTier.values.firstWhere(
      (tier) => tier.name == _prefs.getString(_tierKey),
      orElse: () => SubscriptionTier.rookie,
    );
    final trialStartJson = _prefs.getString(_trialStartKey);
    _trialStart = trialStartJson == null
        ? DateTime.now()
        : DateTime.tryParse(trialStartJson) ?? DateTime.now();
    _prefs.setString(_trialStartKey, _trialStart.toIso8601String());
    _dailyRewardDate = _prefs.getString(_dailyRewardDateKey) ?? _todayStamp();
    _dailyRewardTotal = _prefs.getInt(_dailyRewardTotalKey) ?? 0;
    _resetDailyCapIfNeeded();
  }

  void _resetDailyCapIfNeeded() {
    final today = _todayStamp();
    if (_dailyRewardDate == today) return;
    _dailyRewardDate = today;
    _dailyRewardTotal = 0;
    _prefs.setString(_dailyRewardDateKey, _dailyRewardDate);
    _prefs.setInt(_dailyRewardTotalKey, _dailyRewardTotal);
  }

  String _todayStamp() => _dateStamp(DateTime.now());

  String _dateStamp(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<T> _loadList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final json = _prefs.getString(key);
    if (json == null) return [];
    try {
      final decoded = jsonDecode(json) as List<dynamic>;
      return decoded
          .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      _prefs.remove(key);
      return [];
    }
  }

  void _persistList(String key, List<dynamic> values) {
    _prefs.setString(
      key,
      jsonEncode(values.map((value) => value.toJson()).toList()),
    );
  }

  void _trim(List<dynamic> values, int maxLength) {
    if (values.length > maxLength) {
      values.removeRange(maxLength, values.length);
    }
  }
}
