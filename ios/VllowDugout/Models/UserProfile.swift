import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var displayName: String
    var avatarURL: String
    var vCoins: Int
    var winStreak: Int
    var globalRank: Int
    var drillsCompleted: Int
    var totalTrainingMinutes: Int
    var joinDate: Date

    init(
        displayName: String = "Champion",
        avatarURL: String = "",
        vCoins: Int = 1250,
        winStreak: Int = 12,
        globalRank: Int = 422,
        drillsCompleted: Int = 87,
        totalTrainingMinutes: Int = 2340
    ) {
        self.id = UUID()
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.vCoins = vCoins
        self.winStreak = winStreak
        self.globalRank = globalRank
        self.drillsCompleted = drillsCompleted
        self.totalTrainingMinutes = totalTrainingMinutes
        self.joinDate = Date()
    }
}
