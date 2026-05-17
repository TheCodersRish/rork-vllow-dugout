enum PlayerPosition {
  batter('Batter'),
  bowler('Bowler'),
  allRounder('All-rounder'),
  wicketkeeper('Wicketkeeper');

  final String displayName;
  const PlayerPosition(this.displayName);
}

enum ExperienceLevel {
  beginner('Beginner'),
  club('Club'),
  academy('Academy'),
  representative('Representative');

  final String displayName;
  const ExperienceLevel(this.displayName);
}

class PlayerProfile {
  final DateTime? dateOfBirth;
  final PlayerPosition position;
  final ExperienceLevel experienceLevel;
  final String goals;
  final List<String> weeklyAvailability;
  final String? parentEmail;
  final bool parentConsentGranted;

  const PlayerProfile({
    this.dateOfBirth,
    this.position = PlayerPosition.allRounder,
    this.experienceLevel = ExperienceLevel.club,
    this.goals = 'Build consistency across batting, fielding, and fitness.',
    this.weeklyAvailability = const ['Mon', 'Wed', 'Sat'],
    this.parentEmail,
    this.parentConsentGranted = false,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      position: PlayerPosition.values.firstWhere(
        (position) => position.name == json['position'],
        orElse: () => PlayerPosition.allRounder,
      ),
      experienceLevel: ExperienceLevel.values.firstWhere(
        (level) => level.name == json['experienceLevel'],
        orElse: () => ExperienceLevel.club,
      ),
      goals: json['goals'] as String? ??
          'Build consistency across batting, fielding, and fitness.',
      weeklyAvailability: (json['weeklyAvailability'] as List<dynamic>?)
              ?.map((day) => day as String)
              .toList() ??
          const ['Mon', 'Wed', 'Sat'],
      parentEmail: json['parentEmail'] as String?,
      parentConsentGranted: json['parentConsentGranted'] as bool? ?? false,
    );
  }

  bool get isYouthMode => age != null && age! < 16;

  int? get age {
    final dob = dateOfBirth;
    if (dob == null) return null;

    final now = DateTime.now();
    var calculatedAge = now.year - dob.year;
    final hasHadBirthdayThisYear =
        now.month > dob.month || (now.month == dob.month && now.day >= dob.day);
    if (!hasHadBirthdayThisYear) calculatedAge--;
    return calculatedAge;
  }

  String get ageGroup {
    final playerAge = age;
    if (playerAge == null) return 'Open';
    if (playerAge <= 12) return 'U13';
    if (playerAge <= 14) return 'U15';
    if (playerAge <= 16) return 'U17';
    if (playerAge <= 18) return 'U19';
    return 'Open';
  }

  Map<String, dynamic> toJson() {
    return {
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'position': position.name,
      'experienceLevel': experienceLevel.name,
      'goals': goals,
      'weeklyAvailability': weeklyAvailability,
      'parentEmail': parentEmail,
      'parentConsentGranted': parentConsentGranted,
    };
  }

  PlayerProfile copyWith({
    DateTime? dateOfBirth,
    bool clearDateOfBirth = false,
    PlayerPosition? position,
    ExperienceLevel? experienceLevel,
    String? goals,
    List<String>? weeklyAvailability,
    String? parentEmail,
    bool clearParentEmail = false,
    bool? parentConsentGranted,
  }) {
    return PlayerProfile(
      dateOfBirth: clearDateOfBirth ? null : dateOfBirth ?? this.dateOfBirth,
      position: position ?? this.position,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      goals: goals ?? this.goals,
      weeklyAvailability: weeklyAvailability ?? this.weeklyAvailability,
      parentEmail: clearParentEmail ? null : parentEmail ?? this.parentEmail,
      parentConsentGranted: parentConsentGranted ?? this.parentConsentGranted,
    );
  }
}
