import Foundation

nonisolated struct MealProfile: Codable, Sendable, Hashable {
    var age: Int
    var sex: Sex
    var heightCm: Int
    var weightKg: Int
    var activityLevel: ActivityLevel
    var trainingHoursPerWeek: Int
    var allergies: [String]
    var dislikes: [String]
    var calorieTarget: Int?
    var notes: String

    init(
        age: Int = 22,
        sex: Sex = .male,
        heightCm: Int = 175,
        weightKg: Int = 72,
        activityLevel: ActivityLevel = .high,
        trainingHoursPerWeek: Int = 8,
        allergies: [String] = [],
        dislikes: [String] = [],
        calorieTarget: Int? = nil,
        notes: String = ""
    ) {
        self.age = age
        self.sex = sex
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.activityLevel = activityLevel
        self.trainingHoursPerWeek = trainingHoursPerWeek
        self.allergies = allergies
        self.dislikes = dislikes
        self.calorieTarget = calorieTarget
        self.notes = notes
    }

    var promptDescription: String {
        var parts: [String] = []
        parts.append("\(age) yr old \(sex.rawValue.lowercased()), \(heightCm)cm, \(weightKg)kg")
        parts.append("activity: \(activityLevel.rawValue) (\(trainingHoursPerWeek) training hrs/week)")
        if !allergies.isEmpty { parts.append("ALLERGIES (NEVER include): \(allergies.joined(separator: ", "))") }
        if !dislikes.isEmpty { parts.append("dislikes: \(dislikes.joined(separator: ", "))") }
        if let cal = calorieTarget { parts.append("target ~\(cal) kcal") }
        if !notes.isEmpty { parts.append("notes: \(notes)") }
        return parts.joined(separator: "; ")
    }
}

nonisolated enum Sex: String, Codable, CaseIterable, Sendable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

nonisolated enum ActivityLevel: String, Codable, CaseIterable, Sendable {
    case light = "Light"
    case moderate = "Moderate"
    case high = "High"
    case elite = "Elite"

    var description: String {
        switch self {
        case .light: "Casual play, 1-3 sessions/week"
        case .moderate: "Regular training, 3-5 sessions/week"
        case .high: "Serious athlete, 5-7 sessions/week"
        case .elite: "Pro-level, daily intense training"
        }
    }
}
