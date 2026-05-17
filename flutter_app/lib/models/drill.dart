import 'package:uuid/uuid.dart';

enum DrillCategory {
  batting('Batting'),
  bowling('Bowling'),
  fielding('Fielding'),
  wicketkeeping('Wicketkeeping'),
  masterclass('Masterclass');

  final String displayName;
  const DrillCategory(this.displayName);
}

enum Difficulty {
  beginner('Beginner'),
  intermediate('Intermediate'),
  pro('Pro'),
  elite('Elite');

  final String displayName;
  const Difficulty(this.displayName);
}

class Drill {
  final String id;
  final String title;
  final String subtitle;
  final DrillCategory category;
  final Difficulty difficulty;
  final int durationSeconds;
  final int targetHits;
  final int coinReward;
  final String imageURL;
  final bool isBookmarked;

  Drill({
    String? id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.difficulty,
    required this.durationSeconds,
    required this.targetHits,
    required this.coinReward,
    this.imageURL = '',
    this.isBookmarked = false,
  }) : id = id ?? const Uuid().v4();

  String get durationFormatted {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes}M ${seconds}S';
  }

  Drill copyWith({
    String? id,
    String? title,
    String? subtitle,
    DrillCategory? category,
    Difficulty? difficulty,
    int? durationSeconds,
    int? targetHits,
    int? coinReward,
    String? imageURL,
    bool? isBookmarked,
  }) {
    return Drill(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      targetHits: targetHits ?? this.targetHits,
      coinReward: coinReward ?? this.coinReward,
      imageURL: imageURL ?? this.imageURL,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Drill && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
