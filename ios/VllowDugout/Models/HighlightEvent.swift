import Foundation

struct HighlightEvent: Identifiable, Hashable, Sendable {
    let id: UUID
    /// Peak moment (e.g. crowd cheer) in the source video.
    let peakTimeSeconds: Double
    /// 10s window: 7s before peak → 3s after peak (clamped to asset).
    let clipStartSeconds: Double
    let clipEndSeconds: Double
    let label: String
    let ocrHintMatched: Bool

    var peakFormatted: String {
        formatTime(peakTimeSeconds)
    }

    var clipRangeFormatted: String {
        "\(formatTime(clipStartSeconds)) – \(formatTime(clipEndSeconds))"
    }

    private func formatTime(_ t: Double) -> String {
        let s = Int(t) % 60
        let m = (Int(t) / 60) % 60
        let h = Int(t) / 3600
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }
}
