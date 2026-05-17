import 'dart:math';
import '../models/meal_plan.dart';
import '../models/meal_profile.dart';

class AiMealService {
  static final _rng = Random();

  static int estimateBMR(MealProfile profile) {
    if (profile.sex == Sex.male) {
      return (10 * profile.weightKg + 6.25 * profile.heightCm - 5 * profile.age + 5).round();
    } else {
      return (10 * profile.weightKg + 6.25 * profile.heightCm - 5 * profile.age - 161).round();
    }
  }

  static double activityMultiplier(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.light: return 1.375;
      case ActivityLevel.moderate: return 1.55;
      case ActivityLevel.high: return 1.725;
      case ActivityLevel.elite: return 1.9;
    }
  }

  static int targetCalories(MealProfile? profile, MealGoal goal) {
    if (profile?.calorieTarget != null) return profile!.calorieTarget!;
    final bmr = profile != null ? estimateBMR(profile) : 1800;
    final tdee = (bmr * activityMultiplier(profile?.activityLevel ?? ActivityLevel.high)).round();
    switch (goal) {
      case MealGoal.matchDay: return (tdee * 1.1).round();
      case MealGoal.training: return tdee;
      case MealGoal.recovery: return (tdee * 0.9).round();
      case MealGoal.bulking: return (tdee * 1.2).round();
      case MealGoal.lean: return (tdee * 0.85).round();
    }
  }

  static Future<MealPlan> generatePlan({
    required MealGoal goal,
    required DietPreference diet,
    MealProfile? profile,
  }) async {
    await Future.delayed(Duration(milliseconds: 1200 + _rng.nextInt(800)));

    final totalCal = targetCalories(profile, goal);
    final cuisine = profile?.cuisinePreference ?? CuisinePreference.any;
    final allergies = profile?.allergies.map((a) => a.toLowerCase()).toList() ?? [];

    final breakfastCal = (totalCal * 0.25).round();
    final mornSnackCal = (totalCal * 0.10).round();
    final lunchCal = (totalCal * 0.30).round();
    final aftSnackCal = (totalCal * 0.10).round();
    final dinnerCal = totalCal - breakfastCal - mornSnackCal - lunchCal - aftSnackCal;

    final breakfasts = _getMeals('breakfast', diet, cuisine, allergies);
    final snacks = _getMeals('morningSnack', diet, cuisine, allergies);
    final lunches = _getMeals('lunch', diet, cuisine, allergies);
    final aftSnacks = _getMeals('afternoonSnack', diet, cuisine, allergies);
    final dinners = _getMeals('dinner', diet, cuisine, allergies);

    Meal scaleMeal(Map<String, dynamic> m, MealType type, int cal) {
      final ratio = cal / (m['baseCal'] as int);
      return Meal(
        type: type,
        name: m['name'] as String,
        description: m['description'] as String,
        calories: cal,
        protein: ((m['protein'] as int) * ratio).round(),
        carbs: ((m['carbs'] as int) * ratio).round(),
        fat: ((m['fat'] as int) * ratio).round(),
        ingredients: List<String>.from(m['ingredients'] as List),
        prepTime: m['prepTime'] as String,
      );
    }

    final meals = [
      scaleMeal(breakfasts[_rng.nextInt(breakfasts.length)], MealType.breakfast, breakfastCal),
      scaleMeal(snacks[_rng.nextInt(snacks.length)], MealType.morningSnack, mornSnackCal),
      scaleMeal(lunches[_rng.nextInt(lunches.length)], MealType.lunch, lunchCal),
      scaleMeal(aftSnacks[_rng.nextInt(aftSnacks.length)], MealType.afternoonSnack, aftSnackCal),
      scaleMeal(dinners[_rng.nextInt(dinners.length)], MealType.dinner, dinnerCal),
    ];

    return MealPlan(
      goal: goal,
      diet: diet,
      meals: meals,
      totalCalories: totalCal,
      totalProtein: meals.fold(0, (s, m) => s + m.protein),
      totalCarbs: meals.fold(0, (s, m) => s + m.carbs),
      totalFat: meals.fold(0, (s, m) => s + m.fat),
    );
  }

  static List<Map<String, dynamic>> _getMeals(
    String mealTime, DietPreference diet, CuisinePreference cuisine, List<String> allergies,
  ) {
    final pool = <Map<String, dynamic>>[];

    switch (mealTime) {
      case 'breakfast':
        pool.addAll(_breakfasts(diet, cuisine));
      case 'morningSnack':
        pool.addAll(_morningSnacks(diet, cuisine));
      case 'lunch':
        pool.addAll(_lunches(diet, cuisine));
      case 'afternoonSnack':
        pool.addAll(_afternoonSnacks(diet, cuisine));
      case 'dinner':
        pool.addAll(_dinners(diet, cuisine));
    }

    if (allergies.isEmpty) return pool;
    final filtered = pool.where((item) {
      final ings = (item['ingredients'] as List).map((i) => (i as String).toLowerCase()).toList();
      return !allergies.any((a) => ings.any((ing) => ing.contains(a)));
    }).toList();
    return filtered.isNotEmpty ? filtered : pool.take(1).toList();
  }

  static bool _isIndian(CuisinePreference c) => c == CuisinePreference.indian || c == CuisinePreference.any;
  static bool _isAsian(CuisinePreference c) => c == CuisinePreference.asian || c == CuisinePreference.any;
  static bool _isWestern(CuisinePreference c) => c == CuisinePreference.western || c == CuisinePreference.any;
  static bool _isMed(CuisinePreference c) => c == CuisinePreference.mediterranean || c == CuisinePreference.any;
  static bool _isME(CuisinePreference c) => c == CuisinePreference.middleEastern || c == CuisinePreference.any;

  static List<Map<String, dynamic>> _breakfasts(DietPreference diet, CuisinePreference cuisine) {
    final all = <Map<String, dynamic>>[];
    final isVeg = diet == DietPreference.vegetarian;
    final isVegan = diet == DietPreference.vegan;
    final noMeat = isVeg || isVegan;

    if (_isIndian(cuisine)) {
      if (isVegan) {
        all.add({'name': 'Poha with Peanuts', 'description': 'Flattened rice with turmeric, peanuts & curry leaves', 'baseCal': 420, 'protein': 12, 'carbs': 64, 'fat': 14, 'ingredients': ['Flattened rice', 'Peanuts', 'Onion', 'Turmeric', 'Curry leaves', 'Lemon'], 'prepTime': '12 min'});
        all.add({'name': 'Idli Sambar', 'description': 'Steamed rice cakes with lentil stew', 'baseCal': 380, 'protein': 14, 'carbs': 66, 'fat': 6, 'ingredients': ['Idli batter', 'Toor dal', 'Mixed vegetables', 'Sambar powder', 'Coconut chutney'], 'prepTime': '20 min'});
      } else if (isVeg) {
        all.add({'name': 'Paneer Paratha with Curd', 'description': 'Stuffed whole wheat flatbread with fresh yogurt', 'baseCal': 520, 'protein': 22, 'carbs': 58, 'fat': 22, 'ingredients': ['Whole wheat flour', 'Paneer', 'Spices', 'Ghee', 'Yogurt', 'Pickle'], 'prepTime': '20 min'});
        all.add({'name': 'Upma with Coconut Chutney', 'description': 'Semolina porridge with vegetables', 'baseCal': 400, 'protein': 12, 'carbs': 58, 'fat': 14, 'ingredients': ['Semolina', 'Onion', 'Green chilli', 'Peanuts', 'Curry leaves', 'Coconut chutney'], 'prepTime': '15 min'});
        all.add({'name': 'Moong Dal Chilla', 'description': 'Protein-rich lentil crepes with mint chutney', 'baseCal': 380, 'protein': 20, 'carbs': 48, 'fat': 12, 'ingredients': ['Moong dal', 'Onion', 'Tomato', 'Coriander', 'Green chutney', 'Curd'], 'prepTime': '15 min'});
      } else {
        all.add({'name': 'Egg Bhurji with Roti', 'description': 'Spiced scrambled eggs with whole wheat bread', 'baseCal': 460, 'protein': 26, 'carbs': 42, 'fat': 20, 'ingredients': ['Eggs', 'Onion', 'Tomato', 'Green chilli', 'Whole wheat roti', 'Butter'], 'prepTime': '12 min'});
        all.add({'name': 'Chicken Keema Paratha', 'description': 'Minced chicken stuffed flatbread', 'baseCal': 520, 'protein': 30, 'carbs': 52, 'fat': 22, 'ingredients': ['Whole wheat flour', 'Chicken mince', 'Spices', 'Curd', 'Pickle', 'Onion'], 'prepTime': '25 min'});
      }
    }
    if (_isWestern(cuisine)) {
      if (isVegan) {
        all.add({'name': 'Avocado Toast with Tempeh', 'description': 'Sourdough with smashed avo and crispy tempeh', 'baseCal': 480, 'protein': 20, 'carbs': 48, 'fat': 24, 'ingredients': ['Sourdough bread', 'Avocado', 'Tempeh', 'Cherry tomatoes', 'Lemon', 'Chilli flakes'], 'prepTime': '15 min'});
        all.add({'name': 'Banana Peanut Butter Smoothie Bowl', 'description': 'Thick smoothie with granola and seeds', 'baseCal': 450, 'protein': 16, 'carbs': 58, 'fat': 18, 'ingredients': ['Banana', 'Peanut butter', 'Oat milk', 'Granola', 'Chia seeds', 'Blueberries'], 'prepTime': '10 min'});
      } else if (isVeg) {
        all.add({'name': 'Greek Yogurt Power Bowl', 'description': 'High-protein yogurt with fruit and granola', 'baseCal': 440, 'protein': 28, 'carbs': 52, 'fat': 14, 'ingredients': ['Greek yogurt', 'Mixed berries', 'Granola', 'Honey', 'Pumpkin seeds', 'Flaxseeds'], 'prepTime': '5 min'});
        all.add({'name': 'Overnight Oats', 'description': 'Creamy oats with berries and nuts', 'baseCal': 420, 'protein': 16, 'carbs': 58, 'fat': 14, 'ingredients': ['Rolled oats', 'Yogurt', 'Mixed berries', 'Honey', 'Almonds', 'Chia seeds'], 'prepTime': '5 min'});
      } else {
        all.add({'name': 'Smoked Salmon Avocado Toast', 'description': 'Protein-packed open sandwich', 'baseCal': 480, 'protein': 30, 'carbs': 38, 'fat': 22, 'ingredients': ['Sourdough bread', 'Smoked salmon', 'Avocado', 'Poached eggs', 'Lemon', 'Capers'], 'prepTime': '12 min'});
        all.add({'name': 'Power Oats with Protein', 'description': 'Oats with whey, banana and nut butter', 'baseCal': 520, 'protein': 32, 'carbs': 62, 'fat': 16, 'ingredients': ['Rolled oats', 'Whey protein', 'Banana', 'Almond butter', 'Cinnamon', 'Milk'], 'prepTime': '8 min'});
      }
    }
    if (_isAsian(cuisine)) {
      if (noMeat) {
        all.add({'name': 'Congee with Tofu', 'description': 'Rice porridge with silken tofu and ginger', 'baseCal': 380, 'protein': 16, 'carbs': 58, 'fat': 10, 'ingredients': ['Rice', 'Silken tofu', 'Ginger', 'Spring onions', 'Soy sauce', 'Sesame oil'], 'prepTime': '25 min'});
      } else {
        all.add({'name': 'Nasi Goreng', 'description': 'Indonesian fried rice with egg and chicken', 'baseCal': 500, 'protein': 28, 'carbs': 58, 'fat': 18, 'ingredients': ['Rice', 'Chicken', 'Egg', 'Soy sauce', 'Sambal', 'Spring onions'], 'prepTime': '15 min'});
      }
    }
    if (_isMed(cuisine)) {
      if (noMeat) {
        all.add({'name': 'Shakshuka (Veg)', 'description': 'Spiced tomato stew with chickpeas', 'baseCal': 420, 'protein': 16, 'carbs': 52, 'fat': 18, 'ingredients': ['Chickpeas', 'Tomatoes', 'Bell peppers', 'Cumin', 'Pita bread', 'Olive oil'], 'prepTime': '20 min'});
      } else {
        all.add({'name': 'Turkish Eggs (Cilbir)', 'description': 'Poached eggs on garlic yogurt with chilli butter', 'baseCal': 440, 'protein': 24, 'carbs': 32, 'fat': 24, 'ingredients': ['Eggs', 'Greek yogurt', 'Garlic', 'Butter', 'Chilli flakes', 'Sourdough'], 'prepTime': '15 min'});
      }
    }
    if (_isME(cuisine)) {
      all.add({'name': 'Ful Medames', 'description': 'Stewed fava beans with olive oil and lemon', 'baseCal': 420, 'protein': 18, 'carbs': 56, 'fat': 14, 'ingredients': ['Fava beans', 'Olive oil', 'Lemon', 'Garlic', 'Cumin', 'Pita bread'], 'prepTime': '15 min'});
    }

    if (all.isEmpty) {
      all.add({'name': 'Power Oats Bowl', 'description': 'Oats with banana, honey, and mixed nuts', 'baseCal': 480, 'protein': 18, 'carbs': 72, 'fat': 14, 'ingredients': ['Rolled oats', 'Banana', 'Honey', 'Almonds', 'Chia seeds', 'Milk'], 'prepTime': '10 min'});
    }
    return all;
  }

  static List<Map<String, dynamic>> _morningSnacks(DietPreference diet, CuisinePreference cuisine) {
    final all = <Map<String, dynamic>>[];
    final noMeat = diet == DietPreference.vegetarian || diet == DietPreference.vegan;
    final isVegan = diet == DietPreference.vegan;

    if (_isIndian(cuisine)) {
      all.add({'name': 'Roasted Chana & Fruit', 'description': 'Spiced chickpeas with seasonal fruit', 'baseCal': 200, 'protein': 10, 'carbs': 30, 'fat': 6, 'ingredients': ['Roasted chickpeas', 'Chaat masala', 'Apple', 'Lemon'], 'prepTime': '2 min'});
      if (!isVegan) {
        all.add({'name': 'Lassi with Almonds', 'description': 'Yogurt drink with slivered almonds', 'baseCal': 220, 'protein': 12, 'carbs': 26, 'fat': 8, 'ingredients': ['Yogurt', 'Almonds', 'Cardamom', 'Honey'], 'prepTime': '5 min'});
      }
    }
    if (_isWestern(cuisine) || _isMed(cuisine)) {
      if (isVegan) {
        all.add({'name': 'Trail Mix & Apple', 'description': 'Energy-dense mixed nuts and fruit', 'baseCal': 220, 'protein': 8, 'carbs': 26, 'fat': 12, 'ingredients': ['Almonds', 'Cashews', 'Dried cranberries', 'Pumpkin seeds', 'Apple'], 'prepTime': '2 min'});
      } else {
        all.add({'name': 'Greek Yogurt Parfait', 'description': 'Layered yogurt with berries and granola', 'baseCal': 230, 'protein': 20, 'carbs': 28, 'fat': 6, 'ingredients': ['Greek yogurt', 'Mixed berries', 'Granola', 'Honey'], 'prepTime': '3 min'});
      }
    }
    if (_isAsian(cuisine)) {
      all.add({'name': 'Edamame & Miso Soup', 'description': 'Protein-rich soy snack', 'baseCal': 200, 'protein': 14, 'carbs': 18, 'fat': 8, 'ingredients': ['Edamame', 'Miso paste', 'Tofu', 'Spring onions'], 'prepTime': '5 min'});
    }
    if (all.isEmpty) {
      all.add({'name': 'Mixed Nuts & Banana', 'description': 'Quick energy snack', 'baseCal': 220, 'protein': 8, 'carbs': 28, 'fat': 10, 'ingredients': ['Almonds', 'Walnuts', 'Banana', 'Raisins'], 'prepTime': '2 min'});
    }
    return all;
  }

  static List<Map<String, dynamic>> _lunches(DietPreference diet, CuisinePreference cuisine) {
    final all = <Map<String, dynamic>>[];
    final isVeg = diet == DietPreference.vegetarian;
    final isVegan = diet == DietPreference.vegan;
    final noMeat = isVeg || isVegan;

    if (_isIndian(cuisine)) {
      if (isVegan) {
        all.add({'name': 'Chole with Brown Rice', 'description': 'Spiced chickpea curry with whole grain rice', 'baseCal': 580, 'protein': 20, 'carbs': 82, 'fat': 16, 'ingredients': ['Chickpeas', 'Tomatoes', 'Onion', 'Chole masala', 'Brown rice', 'Coriander'], 'prepTime': '25 min'});
        all.add({'name': 'Rajma Rice', 'description': 'Kidney bean curry with basmati rice', 'baseCal': 560, 'protein': 22, 'carbs': 78, 'fat': 14, 'ingredients': ['Kidney beans', 'Basmati rice', 'Tomato', 'Onion', 'Ginger-garlic', 'Spices'], 'prepTime': '30 min'});
      } else if (isVeg) {
        all.add({'name': 'Paneer Tikka Wrap', 'description': 'Spiced cottage cheese in whole wheat roti with raita', 'baseCal': 580, 'protein': 28, 'carbs': 56, 'fat': 26, 'ingredients': ['Paneer', 'Whole wheat roti', 'Bell peppers', 'Tikka masala', 'Raita', 'Onion'], 'prepTime': '20 min'});
        all.add({'name': 'Dal Fry with Jeera Rice', 'description': 'Yellow lentils with cumin-tempered rice', 'baseCal': 540, 'protein': 22, 'carbs': 74, 'fat': 16, 'ingredients': ['Toor dal', 'Basmati rice', 'Cumin', 'Ghee', 'Tomato', 'Coriander'], 'prepTime': '25 min'});
      } else {
        all.add({'name': 'Chicken Biryani', 'description': 'Fragrant rice with spiced chicken', 'baseCal': 640, 'protein': 38, 'carbs': 68, 'fat': 22, 'ingredients': ['Chicken', 'Basmati rice', 'Biryani masala', 'Yogurt', 'Saffron', 'Raita'], 'prepTime': '35 min'});
        all.add({'name': 'Butter Chicken with Naan', 'description': 'Creamy tomato curry with bread', 'baseCal': 620, 'protein': 36, 'carbs': 56, 'fat': 26, 'ingredients': ['Chicken', 'Tomato', 'Cream', 'Butter', 'Naan', 'Spices'], 'prepTime': '30 min'});
      }
    }
    if (_isWestern(cuisine)) {
      if (noMeat) {
        all.add({'name': 'Mediterranean Quinoa Bowl', 'description': 'Protein grain with roasted vegetables and hummus', 'baseCal': 560, 'protein': 22, 'carbs': 68, 'fat': 22, 'ingredients': ['Quinoa', 'Hummus', 'Roasted peppers', 'Cucumber', 'Feta' + (isVegan ? ' (vegan)' : ''), 'Olive oil'], 'prepTime': '20 min'});
      } else {
        all.add({'name': 'Grilled Chicken Power Bowl', 'description': 'Lean chicken with complex carbs and greens', 'baseCal': 620, 'protein': 44, 'carbs': 58, 'fat': 18, 'ingredients': ['Chicken breast', 'Brown rice', 'Broccoli', 'Sweet potato', 'Olive oil', 'Lemon'], 'prepTime': '25 min'});
        all.add({'name': 'Turkey Club Sandwich', 'description': 'Lean protein sandwich with avocado', 'baseCal': 580, 'protein': 38, 'carbs': 52, 'fat': 22, 'ingredients': ['Turkey breast', 'Whole grain bread', 'Avocado', 'Lettuce', 'Tomato', 'Mustard'], 'prepTime': '10 min'});
      }
    }
    if (_isAsian(cuisine)) {
      if (noMeat) {
        all.add({'name': 'Tofu Pad Thai', 'description': 'Rice noodles with tofu and vegetables', 'baseCal': 540, 'protein': 22, 'carbs': 68, 'fat': 20, 'ingredients': ['Rice noodles', 'Firm tofu', 'Bean sprouts', 'Peanuts', 'Tamarind sauce', 'Lime'], 'prepTime': '20 min'});
      } else {
        all.add({'name': 'Teriyaki Salmon Bowl', 'description': 'Omega-3 rich Japanese-inspired bowl', 'baseCal': 640, 'protein': 38, 'carbs': 62, 'fat': 24, 'ingredients': ['Salmon fillet', 'Sushi rice', 'Edamame', 'Avocado', 'Teriyaki sauce', 'Sesame seeds'], 'prepTime': '25 min'});
      }
    }
    if (_isME(cuisine)) {
      all.add({'name': 'Falafel Plate', 'description': 'Crispy chickpea fritters with tabbouleh and hummus', 'baseCal': 560, 'protein': 20, 'carbs': 66, 'fat': 24, 'ingredients': ['Falafel', 'Hummus', 'Tabbouleh', 'Pita bread', 'Pickles', 'Tahini'], 'prepTime': '20 min'});
    }
    if (all.isEmpty) {
      all.add({'name': 'Balanced Power Bowl', 'description': 'Grain bowl with protein and vegetables', 'baseCal': 580, 'protein': 28, 'carbs': 64, 'fat': 20, 'ingredients': ['Brown rice', 'Mixed beans', 'Avocado', 'Roasted vegetables', 'Olive oil', 'Lemon'], 'prepTime': '20 min'});
    }
    return all;
  }

  static List<Map<String, dynamic>> _afternoonSnacks(DietPreference diet, CuisinePreference cuisine) {
    final all = <Map<String, dynamic>>[];
    final isVegan = diet == DietPreference.vegan;

    if (_isIndian(cuisine)) {
      all.add({'name': 'Masala Chai & Makhana', 'description': 'Spiced tea with roasted fox nuts', 'baseCal': 180, 'protein': 6, 'carbs': 24, 'fat': 8, 'ingredients': ['Fox nuts (makhana)', 'Ghee' + (isVegan ? ' (coconut oil)' : ''), 'Black pepper', 'Tea', 'Cardamom'], 'prepTime': '10 min'});
    }
    if (_isWestern(cuisine)) {
      if (isVegan) {
        all.add({'name': 'Energy Date Balls', 'description': 'No-bake energy bites', 'baseCal': 200, 'protein': 6, 'carbs': 28, 'fat': 10, 'ingredients': ['Medjool dates', 'Almonds', 'Cocoa powder', 'Coconut', 'Vanilla'], 'prepTime': '10 min'});
      } else {
        all.add({'name': 'Protein Banana Shake', 'description': 'Quick post-training shake', 'baseCal': 220, 'protein': 24, 'carbs': 26, 'fat': 6, 'ingredients': ['Whey protein', 'Banana', 'Milk', 'Peanut butter', 'Ice'], 'prepTime': '5 min'});
      }
    }
    if (all.isEmpty) {
      all.add({'name': 'Mixed Nuts & Fruit', 'description': 'Balanced energy snack', 'baseCal': 200, 'protein': 8, 'carbs': 22, 'fat': 10, 'ingredients': ['Almonds', 'Walnuts', 'Dried apricots', 'Dark chocolate'], 'prepTime': '2 min'});
    }
    return all;
  }

  static List<Map<String, dynamic>> _dinners(DietPreference diet, CuisinePreference cuisine) {
    final all = <Map<String, dynamic>>[];
    final isVeg = diet == DietPreference.vegetarian;
    final isVegan = diet == DietPreference.vegan;
    final noMeat = isVeg || isVegan;

    if (_isIndian(cuisine)) {
      if (isVegan) {
        all.add({'name': 'Lentil & Spinach Curry', 'description': 'Comforting protein-rich palak dal', 'baseCal': 500, 'protein': 22, 'carbs': 62, 'fat': 16, 'ingredients': ['Red lentils', 'Spinach', 'Coconut milk', 'Turmeric', 'Cumin', 'Brown rice'], 'prepTime': '30 min'});
        all.add({'name': 'Baingan Bharta with Roti', 'description': 'Smoky mashed aubergine with flatbread', 'baseCal': 460, 'protein': 14, 'carbs': 62, 'fat': 18, 'ingredients': ['Aubergine', 'Onion', 'Tomato', 'Garlic', 'Whole wheat roti', 'Mustard oil'], 'prepTime': '25 min'});
      } else if (isVeg) {
        all.add({'name': 'Dal Makhani with Jeera Rice', 'description': 'Creamy black lentils with aromatic rice', 'baseCal': 560, 'protein': 24, 'carbs': 66, 'fat': 20, 'ingredients': ['Black lentils', 'Kidney beans', 'Cream', 'Basmati rice', 'Cumin', 'Butter'], 'prepTime': '35 min'});
        all.add({'name': 'Palak Paneer with Roti', 'description': 'Spinach and cottage cheese curry', 'baseCal': 540, 'protein': 26, 'carbs': 52, 'fat': 24, 'ingredients': ['Paneer', 'Spinach', 'Cream', 'Garlic', 'Garam masala', 'Whole wheat roti'], 'prepTime': '25 min'});
      } else {
        all.add({'name': 'Chicken Tikka Masala', 'description': 'Classic spiced chicken in creamy sauce', 'baseCal': 620, 'protein': 42, 'carbs': 56, 'fat': 22, 'ingredients': ['Chicken thigh', 'Tikka paste', 'Coconut cream', 'Basmati rice', 'Naan', 'Coriander'], 'prepTime': '35 min'});
        all.add({'name': 'Fish Curry with Rice', 'description': 'Coastal-style fish in tangy gravy', 'baseCal': 560, 'protein': 36, 'carbs': 58, 'fat': 20, 'ingredients': ['White fish', 'Coconut milk', 'Tamarind', 'Curry leaves', 'Basmati rice', 'Mustard seeds'], 'prepTime': '25 min'});
      }
    }
    if (_isWestern(cuisine)) {
      if (noMeat) {
        all.add({'name': 'Stuffed Bell Peppers', 'description': 'Peppers filled with quinoa and black beans', 'baseCal': 520, 'protein': 22, 'carbs': 62, 'fat': 20, 'ingredients': ['Bell peppers', 'Quinoa', 'Black beans', 'Corn', 'Tomato sauce', 'Avocado'], 'prepTime': '30 min'});
      } else {
        all.add({'name': 'Herb-Crusted Salmon', 'description': 'Omega-3 rich dinner for recovery', 'baseCal': 580, 'protein': 40, 'carbs': 42, 'fat': 26, 'ingredients': ['Salmon fillet', 'Mixed herbs', 'Sweet potato', 'Asparagus', 'Olive oil', 'Quinoa'], 'prepTime': '30 min'});
      }
    }
    if (_isAsian(cuisine)) {
      if (noMeat) {
        all.add({'name': 'Tofu Stir-Fry with Soba Noodles', 'description': 'Asian-inspired protein dinner', 'baseCal': 540, 'protein': 24, 'carbs': 58, 'fat': 22, 'ingredients': ['Firm tofu', 'Soba noodles', 'Broccoli', 'Edamame', 'Sesame oil', 'Ginger'], 'prepTime': '25 min'});
      } else {
        all.add({'name': 'Thai Green Curry', 'description': 'Fragrant chicken curry with jasmine rice', 'baseCal': 600, 'protein': 36, 'carbs': 58, 'fat': 24, 'ingredients': ['Chicken', 'Green curry paste', 'Coconut milk', 'Thai basil', 'Jasmine rice', 'Bamboo shoots'], 'prepTime': '25 min'});
      }
    }
    if (_isME(cuisine)) {
      all.add({'name': 'Shawarma Bowl', 'description': noMeat ? 'Spiced chickpea shawarma bowl' : 'Spiced chicken shawarma with tabbouleh', 'baseCal': 580, 'protein': noMeat ? 20 : 36, 'carbs': 58, 'fat': noMeat ? 24 : 22, 'ingredients': noMeat ? ['Chickpeas', 'Tahini', 'Rice', 'Pickled turnip', 'Garlic sauce', 'Flatbread'] : ['Chicken', 'Tahini', 'Rice', 'Pickled turnip', 'Garlic sauce', 'Flatbread'], 'prepTime': '25 min'});
    }
    if (all.isEmpty) {
      all.add({'name': 'Balanced Dinner Bowl', 'description': 'Protein with grains and vegetables', 'baseCal': 560, 'protein': 28, 'carbs': 56, 'fat': 22, 'ingredients': ['Protein of choice', 'Brown rice', 'Mixed vegetables', 'Olive oil', 'Herbs', 'Lemon'], 'prepTime': '25 min'});
    }
    return all;
  }
}
