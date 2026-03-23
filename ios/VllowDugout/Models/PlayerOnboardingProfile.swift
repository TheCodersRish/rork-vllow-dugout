import Foundation

enum PlayingPosition: String, Codable, CaseIterable, Sendable {
    case batsman = "Batsman"
    case bowler = "Bowler"
    case allRounder = "All-Rounder"
    case keeper = "Wicket-Keeper"
}

enum ExperienceLevel: String, Codable, CaseIterable, Sendable {
    case rookie = "Rookie"
    case club = "Club"
    case semiPro = "Semi-Pro"
    case elite = "Elite"
}

enum QuizSkillTier: String, Codable, CaseIterable, Sendable {
    case rookie = "Still building basics"
    case club = "Club competitive"
    case regional = "Regional / high school elite"
    case proPath = "On a pro pathway"
}

enum QuizFitnessLevel: String, Codable, CaseIterable, Sendable {
    case building = "Building back up"
    case matchFit = "Match fit"
    case eliteEngine = "Elite engine"
}

enum DietaryPreference: String, Codable, CaseIterable, Sendable {
    case omnivore = "Omnivore"
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case halal = "Halal-friendly"
}

struct DayConfig: Codable, Equatable, Sendable {
    var isTrainingDay: Bool
    var morning: Bool
    var afternoon: Bool
    var evening: Bool

    static func restDay() -> DayConfig {
        DayConfig(isTrainingDay: false, morning: false, afternoon: false, evening: false)
    }

    static func defaultTraining() -> DayConfig {
        DayConfig(isTrainingDay: true, morning: true, afternoon: false, evening: true)
    }
}

struct WeeklyTrainingSchedule: Codable, Equatable, Sendable {
    /// Calendar weekday: 1 = Sunday ... 7 = Saturday
    var byWeekday: [Int: DayConfig]

    static func empty() -> WeeklyTrainingSchedule {
        var m: [Int: DayConfig] = [:]
        for d in 1...7 { m[d] = .restDay() }
        return WeeklyTrainingSchedule(byWeekday: m)
    }
}

struct PlayerOnboardingProfile: Codable, Equatable, Sendable {
    var displayName: String
    var age: Int
    var position: PlayingPosition
    var experienceLevel: ExperienceLevel
    var goals: [String]
    var quizSkill: QuizSkillTier
    var quizFitness: QuizFitnessLevel
    var dietaryPreference: DietaryPreference
    var weeklySchedule: WeeklyTrainingSchedule
    var bio: String
    var teamName: String
    var leagueName: String
    var profilePhotoJPEGData: Data?
    var parentEmail: String
    var safeguardingAccepted: Bool
    /// Youth confirms a parent/guardian is aware of Expert Review requests (FR-01.7)
    var youthParentAwarenessConfirmed: Bool

    var isYouthMode: Bool { age > 0 && age < 16 }

    static func draft() -> PlayerOnboardingProfile {
        PlayerOnboardingProfile(
            displayName: "",
            age: 18,
            position: .allRounder,
            experienceLevel: .club,
            goals: [],
            quizSkill: .club,
            quizFitness: .matchFit,
            dietaryPreference: .omnivore,
            weeklySchedule: .empty(),
            bio: "",
            teamName: "",
            leagueName: "",
            profilePhotoJPEGData: nil,
            parentEmail: "",
            safeguardingAccepted: false,
            youthParentAwarenessConfirmed: false
        )
    }
}

enum OnboardingProfileStore {
    private static let key = "player_onboarding_profile_v1"

    static func load() -> PlayerOnboardingProfile? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(PlayerOnboardingProfile.self, from: data)
    }

    static func save(_ profile: PlayerOnboardingProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

enum OnboardingGoals {
    static let options: [String] = [
        "Make the first XI",
        "Increase bowling pace",
        "Tighten my line & length",
        "Score faster in T20",
        "Improve keeping reflexes",
        "Mental edge under pressure",
        "Fitness for long spells",
        "Fielding — attack the ball"
    ]
}
