import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum MealType {
  breakfast('Breakfast'),
  morningSnack('Morning Snack'),
  lunch('Lunch'),
  afternoonSnack('Afternoon Snack'),
  dinner('Dinner');

  final String displayName;
  const MealType(this.displayName);

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.morningSnack:
        return Icons.coffee;
      case MealType.lunch:
        return Icons.restaurant;
      case MealType.afternoonSnack:
        return Icons.local_cafe;
      case MealType.dinner:
        return Icons.nights_stay;
    }
  }

  Color get color {
    switch (this) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.morningSnack:
        return Colors.yellow;
      case MealType.lunch:
        return Colors.green;
      case MealType.afternoonSnack:
        return Colors.blue;
      case MealType.dinner:
        return Colors.purple;
    }
  }
}

enum MealGoal {
  matchDay('Match Day'),
  training('Training Day'),
  recovery('Recovery Day'),
  bulking('Muscle Building'),
  lean('Lean Performance');

  final String displayName;
  const MealGoal(this.displayName);

  String get description {
    switch (this) {
      case MealGoal.matchDay:
        return 'High energy for peak match performance';
      case MealGoal.training:
        return 'Fuel intense training sessions';
      case MealGoal.recovery:
        return 'Restore and repair after heavy workload';
      case MealGoal.bulking:
        return 'Build muscle with high protein intake';
      case MealGoal.lean:
        return 'Stay lean while maintaining energy';
    }
  }

  IconData get icon {
    switch (this) {
      case MealGoal.matchDay:
        return Icons.sports_cricket;
      case MealGoal.training:
        return Icons.fitness_center;
      case MealGoal.recovery:
        return Icons.bed;
      case MealGoal.bulking:
        return Icons.fitness_center;
      case MealGoal.lean:
        return Icons.eco;
    }
  }
}

enum DietPreference {
  omnivore('Omnivore'),
  vegetarian('Vegetarian'),
  vegan('Vegan'),
  pescatarian('Pescatarian'),
  halal('Halal');

  final String displayName;
  const DietPreference(this.displayName);

  IconData get icon {
    switch (this) {
      case DietPreference.omnivore:
        return Icons.restaurant;
      case DietPreference.vegetarian:
        return Icons.eco;
      case DietPreference.vegan:
        return Icons.grass;
      case DietPreference.pescatarian:
        return Icons.set_meal;
      case DietPreference.halal:
        return Icons.nightlight_round;
    }
  }

  String get promptRules {
    switch (this) {
      case DietPreference.omnivore:
        return 'No restrictions. Include a balanced mix of meat, poultry, fish, eggs, dairy, and plant foods.';
      case DietPreference.vegetarian:
        return 'STRICTLY VEGETARIAN. Absolutely NO meat, NO poultry, NO fish, NO seafood, NO gelatin, NO meat-based broths or stocks. Eggs and dairy are allowed. Use plant proteins (legumes, beans, lentils, tofu, tempeh, paneer, nuts, seeds, Greek yogurt, cottage cheese, eggs, whey).';
      case DietPreference.vegan:
        return 'STRICTLY VEGAN. NO meat, fish, dairy, eggs, honey, or any animal products. Use only plant-based ingredients (legumes, tofu, tempeh, seitan, plant milks, nuts, seeds, vegan protein powder).';
      case DietPreference.pescatarian:
        return 'Pescatarian: NO meat or poultry. Fish and seafood ARE allowed, plus eggs, dairy, and plant proteins.';
      case DietPreference.halal:
        return 'Halal only. NO pork or pork products, NO alcohol or alcohol-cooked items. All meat must be halal (chicken, beef, lamb, fish allowed).';
    }
  }
}

class Meal {
  final String id;
  final MealType type;
  final String name;
  final String description;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> ingredients;
  final String prepTime;

  Meal({
    String? id,
    required this.type,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.prepTime,
  }) : id = id ?? const Uuid().v4();

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String?,
      type: MealType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MealType.breakfast,
      ),
      name: json['name'] as String,
      description: json['description'] as String,
      calories: json['calories'] as int,
      protein: json['protein'] as int,
      carbs: json['carbs'] as int,
      fat: json['fat'] as int,
      ingredients: List<String>.from(json['ingredients'] as List),
      prepTime: json['prepTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'ingredients': ingredients,
      'prepTime': prepTime,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Meal && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MealPlan {
  final String id;
  final DateTime date;
  final MealGoal goal;
  final DietPreference diet;
  final List<Meal> meals;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;

  MealPlan({
    String? id,
    DateTime? date,
    required this.goal,
    this.diet = DietPreference.omnivore,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      goal: MealGoal.values.firstWhere(
        (e) => e.name == json['goal'],
        orElse: () => MealGoal.training,
      ),
      diet: json['diet'] != null
          ? DietPreference.values.firstWhere(
              (e) => e.name == json['diet'],
              orElse: () => DietPreference.omnivore,
            )
          : DietPreference.omnivore,
      meals: (json['meals'] as List).map((m) => Meal.fromJson(m)).toList(),
      totalCalories: json['totalCalories'] as int,
      totalProtein: json['totalProtein'] as int,
      totalCarbs: json['totalCarbs'] as int,
      totalFat: json['totalFat'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'goal': goal.name,
      'diet': diet.name,
      'meals': meals.map((m) => m.toJson()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }
}
