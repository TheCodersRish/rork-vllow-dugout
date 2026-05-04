import Foundation

nonisolated struct MealPlan: Identifiable, Codable, Sendable {
    let id: UUID
    let date: Date
    let goal: MealGoal
    let diet: DietPreference
    let meals: [Meal]
    let totalCalories: Int
    let totalProtein: Int
    let totalCarbs: Int
    let totalFat: Int

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        goal: MealGoal,
        diet: DietPreference = .omnivore,
        meals: [Meal],
        totalCalories: Int,
        totalProtein: Int,
        totalCarbs: Int,
        totalFat: Int
    ) {
        self.id = id
        self.date = date
        self.goal = goal
        self.diet = diet
        self.meals = meals
        self.totalCalories = totalCalories
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFat = totalFat
    }

    enum CodingKeys: String, CodingKey {
        case id, date, goal, diet, meals, totalCalories, totalProtein, totalCarbs, totalFat
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        date = try c.decode(Date.self, forKey: .date)
        goal = try c.decode(MealGoal.self, forKey: .goal)
        diet = (try? c.decode(DietPreference.self, forKey: .diet)) ?? .omnivore
        meals = try c.decode([Meal].self, forKey: .meals)
        totalCalories = try c.decode(Int.self, forKey: .totalCalories)
        totalProtein = try c.decode(Int.self, forKey: .totalProtein)
        totalCarbs = try c.decode(Int.self, forKey: .totalCarbs)
        totalFat = try c.decode(Int.self, forKey: .totalFat)
    }
}

nonisolated enum DietPreference: String, Codable, CaseIterable, Sendable {
    case omnivore = "Omnivore"
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case pescatarian = "Pescatarian"
    case halal = "Halal"

    var icon: String {
        switch self {
        case .omnivore: "fork.knife"
        case .vegetarian: "leaf.fill"
        case .vegan: "carrot.fill"
        case .pescatarian: "fish.fill"
        case .halal: "moon.fill"
        }
    }

    var promptRules: String {
        switch self {
        case .omnivore:
            return "No restrictions. Include a balanced mix of meat, poultry, fish, eggs, dairy, and plant foods."
        case .vegetarian:
            return "STRICTLY VEGETARIAN. Absolutely NO meat, NO poultry, NO fish, NO seafood, NO gelatin, NO meat-based broths or stocks. Eggs and dairy are allowed. Use plant proteins (legumes, beans, lentils, tofu, tempeh, paneer, nuts, seeds, Greek yogurt, cottage cheese, eggs, whey)."
        case .vegan:
            return "STRICTLY VEGAN. NO meat, fish, dairy, eggs, honey, or any animal products. Use only plant-based ingredients (legumes, tofu, tempeh, seitan, plant milks, nuts, seeds, vegan protein powder)."
        case .pescatarian:
            return "Pescatarian: NO meat or poultry. Fish and seafood ARE allowed, plus eggs, dairy, and plant proteins."
        case .halal:
            return "Halal only. NO pork or pork products, NO alcohol or alcohol-cooked items. All meat must be halal (chicken, beef, lamb, fish allowed)."
        }
    }
}

nonisolated struct Meal: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let type: MealType
    let name: String
    let description: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let ingredients: [String]
    let prepTime: String

    init(
        id: UUID = UUID(),
        type: MealType,
        name: String,
        description: String,
        calories: Int,
        protein: Int,
        carbs: Int,
        fat: Int,
        ingredients: [String],
        prepTime: String
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.description = description
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.ingredients = ingredients
        self.prepTime = prepTime
    }
}

nonisolated enum MealType: String, Codable, CaseIterable, Sendable {
    case breakfast = "Breakfast"
    case morningSnack = "Morning Snack"
    case lunch = "Lunch"
    case afternoonSnack = "Afternoon Snack"
    case dinner = "Dinner"

    var icon: String {
        switch self {
        case .breakfast: "sunrise.fill"
        case .morningSnack: "cup.and.saucer.fill"
        case .lunch: "fork.knife"
        case .afternoonSnack: "takeoutbag.and.cup.and.straw.fill"
        case .dinner: "moon.stars.fill"
        }
    }

    var color: String {
        switch self {
        case .breakfast: "orange"
        case .morningSnack: "yellow"
        case .lunch: "green"
        case .afternoonSnack: "blue"
        case .dinner: "purple"
        }
    }
}

nonisolated enum MealGoal: String, Codable, CaseIterable, Sendable {
    case matchDay = "Match Day"
    case training = "Training Day"
    case recovery = "Recovery Day"
    case bulking = "Muscle Building"
    case lean = "Lean Performance"

    var description: String {
        switch self {
        case .matchDay: "High energy for peak match performance"
        case .training: "Fuel intense training sessions"
        case .recovery: "Restore and repair after heavy workload"
        case .bulking: "Build muscle with high protein intake"
        case .lean: "Stay lean while maintaining energy"
        }
    }

    var icon: String {
        switch self {
        case .matchDay: "cricket.ball.fill"
        case .training: "figure.strengthtraining.traditional"
        case .recovery: "bed.double.fill"
        case .bulking: "dumbbell.fill"
        case .lean: "leaf.fill"
        }
    }
}
