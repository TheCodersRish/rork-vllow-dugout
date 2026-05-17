import 'dart:math';
import 'package:flutter/foundation.dart';

class HealthDataPoint {
  final String type;
  final double value;
  final String unit;
  final DateTime date;

  HealthDataPoint({
    required this.type,
    required this.value,
    required this.unit,
    required this.date,
  });
}

class HealthSummary {
  final int steps;
  final int activeCalories;
  final int restingHeartRate;
  final double distanceKm;
  final int exerciseMinutes;
  final int standHours;
  final double sleepHours;
  final int vo2Max;
  final List<HealthDataPoint> heartRateHistory;
  final List<HealthDataPoint> stepsHistory;

  HealthSummary({
    required this.steps,
    required this.activeCalories,
    required this.restingHeartRate,
    required this.distanceKm,
    required this.exerciseMinutes,
    required this.standHours,
    required this.sleepHours,
    required this.vo2Max,
    this.heartRateHistory = const [],
    this.stepsHistory = const [],
  });
}

class HealthService extends ChangeNotifier {
  bool _isAuthorized = false;
  bool _isLoading = false;
  HealthSummary? _todaySummary;
  HealthSummary? _weekSummary;
  String? _errorMessage;

  bool get isAuthorized => _isAuthorized;
  bool get isLoading => _isLoading;
  HealthSummary? get todaySummary => _todaySummary;
  HealthSummary? get weekSummary => _weekSummary;
  String? get errorMessage => _errorMessage;

  bool get isAvailable => !kIsWeb;

  Future<void> requestAuthorization() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (kIsWeb) {
      _errorMessage = 'Health data requires a mobile device';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isAuthorized = true;
    _isLoading = false;
    notifyListeners();

    await fetchTodayData();
    await fetchWeekData();
  }

  Future<void> fetchTodayData() async {
    if (!_isAuthorized && !kIsWeb) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final rng = Random();
    final now = DateTime.now();

    _todaySummary = HealthSummary(
      steps: 6200 + rng.nextInt(4000),
      activeCalories: 280 + rng.nextInt(220),
      restingHeartRate: 58 + rng.nextInt(10),
      distanceKm: 3.5 + rng.nextDouble() * 4.0,
      exerciseMinutes: 30 + rng.nextInt(60),
      standHours: 6 + rng.nextInt(6),
      sleepHours: 6.5 + rng.nextDouble() * 2.0,
      vo2Max: 42 + rng.nextInt(12),
      heartRateHistory: List.generate(24, (i) {
        return HealthDataPoint(
          type: 'heartRate',
          value: 60 + rng.nextInt(40).toDouble(),
          unit: 'bpm',
          date: now.subtract(Duration(hours: 24 - i)),
        );
      }),
      stepsHistory: List.generate(7, (i) {
        return HealthDataPoint(
          type: 'steps',
          value: (4000 + rng.nextInt(8000)).toDouble(),
          unit: 'steps',
          date: now.subtract(Duration(days: 6 - i)),
        );
      }),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWeekData() async {
    if (!_isAuthorized && !kIsWeb) return;

    final rng = Random();

    _weekSummary = HealthSummary(
      steps: 45000 + rng.nextInt(25000),
      activeCalories: 2200 + rng.nextInt(1000),
      restingHeartRate: 58 + rng.nextInt(8),
      distanceKm: 28.0 + rng.nextDouble() * 15.0,
      exerciseMinutes: 180 + rng.nextInt(200),
      standHours: 42 + rng.nextInt(20),
      sleepHours: 48 + rng.nextDouble() * 10,
      vo2Max: 42 + rng.nextInt(12),
    );

    notifyListeners();
  }
}
