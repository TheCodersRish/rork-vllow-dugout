import Foundation

nonisolated struct Drill: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let category: DrillCategory
    let difficulty: Difficulty
    let durationSeconds: Int
    let targetHits: Int
    let coinReward: Int
    let imageURL: String
    let isBookmarked: Bool

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        category: DrillCategory,
        difficulty: Difficulty,
        durationSeconds: Int,
        targetHits: Int,
        coinReward: Int,
        imageURL: String = "",
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.difficulty = difficulty
        self.durationSeconds = durationSeconds
        self.targetHits = targetHits
        self.coinReward = coinReward
        self.imageURL = imageURL
        self.isBookmarked = isBookmarked
    }

    var durationFormatted: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        return "\(minutes)M \(seconds)S"
    }
}

nonisolated enum DrillCategory: String, CaseIterable, Sendable {
    case batting = "Batting"
    case bowling = "Bowling"
    case fielding = "Fielding"
    case wicketkeeping = "Wicketkeeping"
    case masterclass = "Masterclass"
}

nonisolated enum Difficulty: String, CaseIterable, Sendable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case pro = "Pro"
    case elite = "Elite"
}
