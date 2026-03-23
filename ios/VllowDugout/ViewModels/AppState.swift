import SwiftUI
import SwiftData

@Observable
@MainActor
class AppState {
    var selectedTab: AppTab = .feed
    let gameData: GameDataService
    var showCoinEarned: Bool = false
    var lastCoinReason: String = ""

    init() {
        self.gameData = GameDataService()
    }

    var vCoins: Int { gameData.vCoins }
    var winStreak: Int { gameData.winStreak }
    var globalRank: Int { gameData.globalRank }
    var drillsCompleted: Int { gameData.drillsCompleted }

    func toggleBookmark(for drillID: UUID) {
        gameData.toggleBookmark(for: drillID)
    }

    func isBookmarked(_ drillID: UUID) -> Bool {
        gameData.isBookmarked(drillID)
    }

    func earnCoinsWithFeedback(_ amount: Int, reason: String) {
        gameData.earnCoins(amount, reason: reason)
        lastCoinReason = "+\(amount) V-Coins: \(reason)"
        withAnimation(.spring(response: 0.4)) {
            showCoinEarned = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation { showCoinEarned = false }
        }
    }
}

nonisolated enum AppTab: Int, CaseIterable, Sendable {
    case feed
    case coach
    case intel
    case fuel
    case arena
    case store

    var title: String {
        switch self {
        case .feed: "Feed"
        case .coach: "Coach"
        case .intel: "Intel"
        case .fuel: "Fuel"
        case .arena: "Arena"
        case .store: "Store"
        }
    }

    var icon: String {
        switch self {
        case .feed: "rectangle.stack.fill"
        case .coach: "brain.head.profile"
        case .intel: "chart.bar.fill"
        case .fuel: "fork.knife"
        case .arena: "trophy.fill"
        case .store: "bag.fill"
        }
    }
}
