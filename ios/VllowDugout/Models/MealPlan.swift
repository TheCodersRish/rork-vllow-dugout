import Foundation

nonisolated struct MealPlan: Identifiable, Codable, Sendable {
    let id: UUID
    let date: Date
    let goal: MealGoal
    let meals: [Meal]
    let totalCalories: Int
    let totalProtein: Int
    let totalCarbs: Int
    let totalFat: Int

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        goal: MealGoal,
        meals: [Meal],
        totalCalories: Int,
        totalProtein: Int,
        totalCarbs: Int,
        totalFat: Int
    ) {
        self.id = id
        self.date = date
        self.goal = goal
        self.meals = meals
        self.totalCalories = totalCalories
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFat = totalFat
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
