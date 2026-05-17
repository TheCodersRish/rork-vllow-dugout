import 'package:uuid/uuid.dart';

class PerformanceStats {
  final int runsScored;
  final int ballsFaced;
  final double strikeRateChange;
  final String opponent;
  final int coinBonus;
  final DateTime recordedAt;

  PerformanceStats({
    required this.runsScored,
    required this.ballsFaced,
    required this.strikeRateChange,
    required this.opponent,
    required this.coinBonus,
    DateTime? recordedAt,
  }) : recordedAt = recordedAt ?? DateTime.now();

  factory PerformanceStats.fromJson(Map<String, dynamic> json) {
    return PerformanceStats(
      runsScored: json['runsScored'] as int,
      ballsFaced: json['ballsFaced'] as int,
      strikeRateChange: (json['strikeRateChange'] as num).toDouble(),
      opponent: json['opponent'] as String,
      coinBonus: json['coinBonus'] as int,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }

  double get strikeRate {
    if (ballsFaced <= 0) return 0;
    return (runsScored / ballsFaced) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'runsScored': runsScored,
      'ballsFaced': ballsFaced,
      'strikeRateChange': strikeRateChange,
      'opponent': opponent,
      'coinBonus': coinBonus,
      'recordedAt': recordedAt.toIso8601String(),
    };
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
