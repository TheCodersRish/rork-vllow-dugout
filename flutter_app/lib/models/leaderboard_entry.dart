import 'package:uuid/uuid.dart';

enum LeaderboardPeriod {
  weekly('Weekly'),
  monthly('Monthly'),
  allTime('All-Time');

  final String displayName;
  const LeaderboardPeriod(this.displayName);
}

class LeaderboardEntry {
  final String id;
  final int rank;
  final String playerName;
  final String avatarURL;
  final int vCoins;
  final int drillsCompleted;
  final bool isCurrentUser;

  LeaderboardEntry({
    String? id,
    required this.rank,
    required this.playerName,
    this.avatarURL = '',
    required this.vCoins,
    required this.drillsCompleted,
    this.isCurrentUser = false,
  }) : id = id ?? const Uuid().v4();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LeaderboardEntry && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
