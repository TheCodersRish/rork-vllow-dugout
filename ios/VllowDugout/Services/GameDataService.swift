import Foundation

@Observable
@MainActor
class GameDataService {
    var vCoins: Int {
        didSet { save("vCoins", vCoins) }
    }
    var winStreak: Int {
        didSet { save("winStreak", winStreak) }
    }
    var globalRank: Int {
        didSet { save("globalRank", globalRank) }
    }
    var drillsCompleted: Int {
        didSet { save("drillsCompleted", drillsCompleted) }
    }
    var totalTrainingSeconds: Int {
        didSet { save("totalTrainingSeconds", totalTrainingSeconds) }
    }
    var coachSessionCount: Int {
        didSet { save("coachSessionCount", coachSessionCount) }
    }
    var completedDrillIDs: Set<String> {
        didSet { save("completedDrillIDs", Array(completedDrillIDs)) }
    }
    var bookmarkedDrillIDs: Set<String> {
        didSet { save("bookmarkedDrillIDs", Array(bookmarkedDrillIDs)) }
    }
    var redeemedProductIDs: Set<String> {
        didSet { save("redeemedProductIDs", Array(redeemedProductIDs)) }
    }
    var matchHistory: [MatchRecord] {
        didSet {
            if let data = try? JSONEncoder().encode(matchHistory) {
                UserDefaults.standard.set(data, forKey: key("matchHistory"))
            }
        }
    }
    var dailyMissionCompletedDate: String {
        didSet { save("dailyMissionCompletedDate", dailyMissionCompletedDate) }
    }
    var currentDailyDrillIndex: Int {
        didSet { save("currentDailyDrillIndex", currentDailyDrillIndex) }
    }

    private let prefix = "vllow_game_"

    init() {
        let ud = UserDefaults.standard
        vCoins = ud.object(forKey: "vllow_game_vCoins") as? Int ?? 250
        winStreak = ud.object(forKey: "vllow_game_winStreak") as? Int ?? 0
        globalRank = ud.object(forKey: "vllow_game_globalRank") as? Int ?? 999
        drillsCompleted = ud.object(forKey: "vllow_game_drillsCompleted") as? Int ?? 0
        totalTrainingSeconds = ud.object(forKey: "vllow_game_totalTrainingSeconds") as? Int ?? 0
        coachSessionCount = ud.object(forKey: "vllow_game_coachSessionCount") as? Int ?? 0
        dailyMissionCompletedDate = ud.string(forKey: "vllow_game_dailyMissionCompletedDate") ?? ""
        currentDailyDrillIndex = ud.object(forKey: "vllow_game_currentDailyDrillIndex") as? Int ?? 0

        if let arr = ud.array(forKey: "vllow_game_completedDrillIDs") as? [String] {
            completedDrillIDs = Set(arr)
        } else {
            completedDrillIDs = []
        }
        if let arr = ud.array(forKey: "vllow_game_bookmarkedDrillIDs") as? [String] {
            bookmarkedDrillIDs = Set(arr)
        } else {
            bookmarkedDrillIDs = []
        }
        if let arr = ud.array(forKey: "vllow_game_redeemedProductIDs") as? [String] {
            redeemedProductIDs = Set(arr)
        } else {
            redeemedProductIDs = []
        }
        if let data = ud.data(forKey: "vllow_game_matchHistory"),
           let decoded = try? JSONDecoder().decode([MatchRecord].self, from: data) {
            matchHistory = decoded
        } else {
            matchHistory = []
        }

        rotateDailyMissionIfNeeded()
    }

    func earnCoins(_ amount: Int, reason: String) {
        vCoins += amount
        let record = CoinTransaction(amount: amount, reason: reason, date: Date())
        var transactions = loadTransactions()
        transactions.append(record)
        if let data = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(data, forKey: key("coinTransactions"))
        }
    }

    func spendCoins(_ amount: Int) -> Bool {
        guard vCoins >= amount else { return false }
        vCoins -= amount
        return true
    }

    func completeDrill(_ drill: Drill) {
        let idStr = drill.id.uuidString
        guard !completedDrillIDs.contains(idStr) || !isDailyMissionCompleted else { return }
        completedDrillIDs.insert(idStr)
        drillsCompleted += 1
        totalTrainingSeconds += drill.durationSeconds
        earnCoins(drill.coinReward, reason: "Completed \(drill.title)")
        updateWinStreak()
        recalculateRank()
    }

    func completeDailyMission(_ drill: Drill) {
        let today = todayString()
        guard dailyMissionCompletedDate != today else { return }
        dailyMissionCompletedDate = today
        drillsCompleted += 1
        totalTrainingSeconds += drill.durationSeconds
        let bonus = drill.coinReward * 2
        earnCoins(bonus, reason: "Daily Mission: \(drill.title)")
        updateWinStreak()
        recalculateRank()
    }

    var isDailyMissionCompleted: Bool {
        dailyMissionCompletedDate == todayString()
    }

    func recordMatch(runs: Int, balls: Int, opponent: String) {
        let sr = balls > 0 ? (Double(runs) / Double(balls)) * 100 : 0
        let coinBonus = calculateMatchBonus(runs: runs, strikeRate: sr)
        let record = MatchRecord(
            runs: runs,
            ballsFaced: balls,
            strikeRate: sr,
            opponent: opponent,
            coinBonus: coinBonus,
            date: Date()
        )
        matchHistory.insert(record, at: 0)
        if matchHistory.count > 50 { matchHistory = Array(matchHistory.prefix(50)) }
        earnCoins(coinBonus, reason: "Match vs \(opponent)")
        recalculateRank()
    }

    func coachSessionCompleted() {
        coachSessionCount += 1
    }

    func redeemProduct(_ product: Product) -> Bool {
        guard spendCoins(product.priceCoins) else { return false }
        redeemedProductIDs.insert(product.id.uuidString)
        return true
    }

    func toggleBookmark(for drillID: UUID) {
        let str = drillID.uuidString
        if bookmarkedDrillIDs.contains(str) {
            bookmarkedDrillIDs.remove(str)
        } else {
            bookmarkedDrillIDs.insert(str)
        }
    }

    func isBookmarked(_ drillID: UUID) -> Bool {
        bookmarkedDrillIDs.contains(drillID.uuidString)
    }

    func isRedeemed(_ productID: UUID) -> Bool {
        redeemedProductIDs.contains(productID.uuidString)
    }

    var isDoubleCoinWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == 1 || weekday == 7
    }

    var latestMatch: MatchRecord? {
        matchHistory.first
    }

    var averageStrikeRate: Double {
        guard !matchHistory.isEmpty else { return 0 }
        let total = matchHistory.reduce(0.0) { $0 + $1.strikeRate }
        return total / Double(matchHistory.count)
    }

    var totalRuns: Int {
        matchHistory.reduce(0) { $0 + $1.runs }
    }

    var currentDailyDrill: Drill {
        let drills = MockData.drills
        let idx = currentDailyDrillIndex % drills.count
        return drills[idx]
    }

    var leaderboard: [LeaderboardEntry] {
        generateLeaderboard()
    }

    func loadTransactions() -> [CoinTransaction] {
        guard let data = UserDefaults.standard.data(forKey: key("coinTransactions")),
              let decoded = try? JSONDecoder().decode([CoinTransaction].self, from: data) else {
            return []
        }
        return decoded
    }

    private func rotateDailyMissionIfNeeded() {
        let today = todayString()
        let lastDate = UserDefaults.standard.string(forKey: key("lastDailyRotationDate")) ?? ""
        if lastDate != today {
            currentDailyDrillIndex = (currentDailyDrillIndex + 1) % MockData.drills.count
            UserDefaults.standard.set(today, forKey: key("lastDailyRotationDate"))
        }
    }

    private func updateWinStreak() {
        let lastActive = UserDefaults.standard.string(forKey: key("lastActiveDate")) ?? ""
        let today = todayString()
        let yesterday = yesterdayString()

        if lastActive == today {
            return
        } else if lastActive == yesterday {
            winStreak += 1
        } else if lastActive.isEmpty {
            winStreak = 1
        } else {
            winStreak = 1
        }
        UserDefaults.standard.set(today, forKey: key("lastActiveDate"))
    }

    private func recalculateRank() {
        let score = vCoins + (drillsCompleted * 10) + (winStreak * 5)
        if score > 5000 {
            globalRank = max(1, Int.random(in: 10...50))
        } else if score > 2000 {
            globalRank = max(1, Int.random(in: 50...200))
        } else if score > 500 {
            globalRank = max(1, Int.random(in: 200...500))
        } else {
            globalRank = max(1, Int.random(in: 500...999))
        }
    }

    private func calculateMatchBonus(runs: Int, strikeRate: Double) -> Int {
        var bonus = runs * 3
        if strikeRate > 150 { bonus += 100 }
        else if strikeRate > 120 { bonus += 50 }
        if runs >= 50 { bonus += 150 }
        if runs >= 100 { bonus += 300 }
        return bonus
    }

    private func generateLeaderboard() -> [LeaderboardEntry] {
        var entries = MockData.baseLeaderboard
        let userRank = globalRank
        let userEntry = LeaderboardEntry(
            rank: userRank,
            playerName: "You",
            vCoins: vCoins,
            drillsCompleted: drillsCompleted,
            isCurrentUser: true
        )

        entries = entries.filter { $0.rank != userRank && !$0.isCurrentUser }

        let nearbyBefore = LeaderboardEntry(
            rank: max(1, userRank - 1),
            playerName: MockData.randomNames.randomElement() ?? "Player",
            vCoins: vCoins + Int.random(in: 10...100),
            drillsCompleted: drillsCompleted + Int.random(in: 1...5)
        )
        let nearbyAfter = LeaderboardEntry(
            rank: userRank + 1,
            playerName: MockData.randomNames.randomElement() ?? "Player",
            vCoins: max(0, vCoins - Int.random(in: 10...100)),
            drillsCompleted: max(0, drillsCompleted - Int.random(in: 0...3))
        )

        entries.append(userEntry)
        if userRank > 3 {
            entries.append(nearbyBefore)
            entries.append(nearbyAfter)
        }

        entries.sort { $0.rank < $1.rank }
        return entries
    }

    private func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private func yesterdayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return f.string(from: yesterday)
    }

    private func key(_ name: String) -> String {
        "\(prefix)\(name)"
    }

    private func save(_ name: String, _ value: Int) {
        UserDefaults.standard.set(value, forKey: key(name))
    }

    private func save(_ name: String, _ value: String) {
        UserDefaults.standard.set(value, forKey: key(name))
    }

    private func save(_ name: String, _ value: [String]) {
        UserDefaults.standard.set(value, forKey: key(name))
    }
}

nonisolated struct MatchRecord: Codable, Sendable, Identifiable {
    let id: UUID
    let runs: Int
    let ballsFaced: Int
    let strikeRate: Double
    let opponent: String
    let coinBonus: Int
    let date: Date

    init(id: UUID = UUID(), runs: Int, ballsFaced: Int, strikeRate: Double, opponent: String, coinBonus: Int, date: Date = Date()) {
        self.id = id
        self.runs = runs
        self.ballsFaced = ballsFaced
        self.strikeRate = strikeRate
        self.opponent = opponent
        self.coinBonus = coinBonus
        self.date = date
    }
}

nonisolated struct CoinTransaction: Codable, Sendable, Identifiable {
    let id: UUID
    let amount: Int
    let reason: String
    let date: Date

    init(id: UUID = UUID(), amount: Int, reason: String, date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.reason = reason
        self.date = date
    }
}
