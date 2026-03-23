import Foundation

enum MealSlot: String, CaseIterable, Sendable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
}

enum MealPlanCategory: String, CaseIterable, Sendable {
    case all = "All"
    case training = "Training"
    case matchDay = "Match Day"
    case recovery = "Recovery"
    case vegetarian = "Vegetarian"
}

struct MealPlanItem: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let slot: MealSlot
    let category: MealPlanCategory
    let calories: Int
    let proteinG: Int
    let carbsG: Int
    let fatG: Int
    let highlight: String
    let imageURL: String
    let prepMinutes: Int
    let ingredients: [String]
    let chefNotes: String
}
