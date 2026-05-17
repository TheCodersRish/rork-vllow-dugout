import 'package:uuid/uuid.dart';

class UserProfile {
  final String id;
  String displayName;
  String avatarURL;
  int vCoins;
  int winStreak;
  int globalRank;
  int drillsCompleted;
  int totalTrainingMinutes;
  final DateTime joinDate;

  UserProfile({
    String? id,
    this.displayName = 'Champion',
    this.avatarURL = '',
    this.vCoins = 1250,
    this.winStreak = 12,
    this.globalRank = 422,
    this.drillsCompleted = 87,
    this.totalTrainingMinutes = 2340,
    DateTime? joinDate,
  })  : id = id ?? const Uuid().v4(),
        joinDate = joinDate ?? DateTime.now();
}
