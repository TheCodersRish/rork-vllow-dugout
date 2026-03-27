import Foundation

nonisolated struct PerformanceStats: Sendable {
    let runsScored: Int
    let ballsFaced: Int
    let strikeRateChange: Double
    let opponent: String
    let coinBonus: Int

    var strikeRate: Double {
        guard ballsFaced > 0 else { return 0 }
        return (Double(runsScored) / Double(ballsFaced)) * 100
    }
}

nonisolated struct ScoringZone: Identifiable, Sendable {
    let id: UUID
    let name: String
    let runs: Int
    let xPosition: Double
    let yPosition: Double
    let intensity: Double

    init(id: UUID = UUID(), name: String, runs: Int, xPosition: Double, yPosition: Double, intensity: Double) {
        self.id = id
        self.name = name
        self.runs = runs
        self.xPosition = xPosition
        self.yPosition = yPosition
        self.intensity = intensity
    }
}

nonisolated struct DismissalPattern: Identifiable, Sendable {
    let id: UUID
    let type: String
    let percentage: Double

    init(id: UUID = UUID(), type: String, percentage: Double) {
        self.id = id
        self.type = type
        self.percentage = percentage
    }
}
