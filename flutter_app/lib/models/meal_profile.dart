import 'dart:convert';
import 'meal_plan.dart';

enum Sex {
  male('Male'),
  female('Female'),
  other('Other');

  final String displayName;
  const Sex(this.displayName);
}

enum ActivityLevel {
  light('Light'),
  moderate('Moderate'),
  high('High'),
  elite('Elite');

  final String displayName;
  const ActivityLevel(this.displayName);

  String get description {
    switch (this) {
      case ActivityLevel.light:
        return 'Casual play, 1-3 sessions/week';
      case ActivityLevel.moderate:
        return 'Regular training, 3-5 sessions/week';
      case ActivityLevel.high:
        return 'Serious athlete, 5-7 sessions/week';
      case ActivityLevel.elite:
        return 'Pro-level, daily intense training';
    }
  }
}

enum CuisinePreference {
  any('No Preference'),
  indian('Indian'),
  mediterranean('Mediterranean'),
  asian('Asian'),
  western('Western'),
  middleEastern('Middle Eastern');

  final String displayName;
  const CuisinePreference(this.displayName);
}

class MealProfile {
  int age;
  Sex sex;
  int heightCm;
  int weightKg;
  ActivityLevel activityLevel;
  int trainingHoursPerWeek;
  DietPreference dietPreference;
  CuisinePreference cuisinePreference;
  List<String> allergies;
  List<String> dislikes;
  int? calorieTarget;
  String notes;

  MealProfile({
    this.age = 22,
    this.sex = Sex.male,
    this.heightCm = 175,
    this.weightKg = 72,
    this.activityLevel = ActivityLevel.high,
    this.trainingHoursPerWeek = 8,
    this.dietPreference = DietPreference.omnivore,
    this.cuisinePreference = CuisinePreference.any,
    this.allergies = const [],
    this.dislikes = const [],
    this.calorieTarget,
    this.notes = '',
  });

  String get promptDescription {
    final parts = <String>[];
    parts.add(
        '$age yr old ${sex.displayName.toLowerCase()}, ${heightCm}cm, ${weightKg}kg');
    parts.add(
        'activity: ${activityLevel.displayName} ($trainingHoursPerWeek training hrs/week)');
    parts.add('diet: ${dietPreference.displayName}');
    if (cuisinePreference != CuisinePreference.any) {
      parts.add('cuisine: ${cuisinePreference.displayName}');
    }
    if (allergies.isNotEmpty) {
      parts.add('ALLERGIES (NEVER include): ${allergies.join(', ')}');
    }
    if (dislikes.isNotEmpty) {
      parts.add('dislikes: ${dislikes.join(', ')}');
    }
    if (calorieTarget != null) {
      parts.add('target ~$calorieTarget kcal');
    }
    if (notes.isNotEmpty) {
      parts.add('notes: $notes');
    }
    return parts.join('; ');
  }

  factory MealProfile.fromJson(Map<String, dynamic> json) {
    return MealProfile(
      age: json['age'] as int? ?? 22,
      sex: Sex.values.firstWhere(
        (e) => e.name == json['sex'],
        orElse: () => Sex.male,
      ),
      heightCm: json['heightCm'] as int? ?? 175,
      weightKg: json['weightKg'] as int? ?? 72,
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == json['activityLevel'],
        orElse: () => ActivityLevel.high,
      ),
      trainingHoursPerWeek: json['trainingHoursPerWeek'] as int? ?? 8,
      dietPreference: json['dietPreference'] != null
          ? DietPreference.values.firstWhere(
              (e) => e.name == json['dietPreference'],
              orElse: () => DietPreference.omnivore,
            )
          : DietPreference.omnivore,
      cuisinePreference: json['cuisinePreference'] != null
          ? CuisinePreference.values.firstWhere(
              (e) => e.name == json['cuisinePreference'],
              orElse: () => CuisinePreference.any,
            )
          : CuisinePreference.any,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'] as List)
          : [],
      dislikes: json['dislikes'] != null
          ? List<String>.from(json['dislikes'] as List)
          : [],
      calorieTarget: json['calorieTarget'] as int?,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'sex': sex.name,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel.name,
      'trainingHoursPerWeek': trainingHoursPerWeek,
      'dietPreference': dietPreference.name,
      'cuisinePreference': cuisinePreference.name,
      'allergies': allergies,
      'dislikes': dislikes,
      'calorieTarget': calorieTarget,
      'notes': notes,
    };
  }
}
