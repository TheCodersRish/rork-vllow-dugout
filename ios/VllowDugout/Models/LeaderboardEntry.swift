import Foundation

nonisolated struct LeaderboardEntry: Identifiable, Hashable, Sendable {
    let id: UUID
    let rank: Int
    let playerName: String
    let avatarURL: String
    let vCoins: Int
    let drillsCompleted: Int
    let isCurrentUser: Bool

    init(
        id: UUID = UUID(),
        rank: Int,
        playerName: String,
        avatarURL: String = "",
        vCoins: Int,
        drillsCompleted: Int,
        isCurrentUser: Bool = false
    ) {
        self.id = id
        self.rank = rank
        self.playerName = playerName
        self.avatarURL = avatarURL
        self.vCoins = vCoins
        self.drillsCompleted = drillsCompleted
        self.isCurrentUser = isCurrentUser
    }
}

nonisolated enum LeaderboardPeriod: String, CaseIterable, Sendable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case allTime = "All-Time"
}
