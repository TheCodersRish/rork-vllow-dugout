import 'package:uuid/uuid.dart';

class PerformanceStats {
  final int runsScored;
  final int ballsFaced;
  final double strikeRateChange;
  final String opponent;
  final int coinBonus;

  PerformanceStats({
    required this.runsScored,
    required this.ballsFaced,
    required this.strikeRateChange,
    required this.opponent,
    required this.coinBonus,
  });

  double get strikeRate {
    if (ballsFaced <= 0) return 0;
    return (runsScored / ballsFaced) * 100;
  }
}

class ScoringZone {
  final String id;
  final String name;
  final int runs;
  final double xPosition;
  final double yPosition;
  final double intensity;

  ScoringZone({
    String? id,
    required this.name,
    required this.runs,
    required this.xPosition,
    required this.yPosition,
    required this.intensity,
  }) : id = id ?? const Uuid().v4();
}

class DismissalPattern {
  final String id;
  final String type;
  final double percentage;

  DismissalPattern({
    String? id,
    required this.type,
    required this.percentage,
  }) : id = id ?? const Uuid().v4();
}
