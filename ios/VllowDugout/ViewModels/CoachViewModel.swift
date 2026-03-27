import SwiftUI
import Foundation

@Observable
@MainActor
class CoachViewModel {
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var focusTopic: String = "Front-Foot Precision"
    var sessionMessageCount: Int = 0
    var showQuickActions: Bool = false

    private var appState: AppState?

    private var systemPrompt: String {
        let stats = buildStatsContext()
        return """
        You are FR-03, an elite AI cricket coaching assistant for Vllow Dugout. \
        You analyze player technique, suggest drills, and provide expert cricket coaching advice. \
        Keep responses concise (2-4 sentences max), actionable, and encouraging. Use cricket terminology naturally. \
        Focus on batting, bowling, fielding technique, mental game, and fitness for cricket. \
        Always be motivating and push the player to improve. Reference specific techniques and drills. \
        \(stats) \
        When the user asks about a drill or technique, give specific tips they can practice right now. \
        End responses with a clear next step or suggestion.
        """
    }

    private func buildStatsContext() -> String {
        guard let appState else { return "" }
        let gd = appState.gameData
        var ctx = "Player stats: \(gd.vCoins) V-Coins, \(gd.drillsCompleted) drills completed, \(gd.winStreak)-day streak, rank #\(gd.globalRank)."
        if let match = gd.latestMatch {
            ctx += " Latest match: \(match.runs) runs off \(match.ballsFaced) balls (SR: \(String(format: "%.1f", match.strikeRate))) vs \(match.opponent)."
        }
        if gd.totalTrainingSeconds > 0 {
            let mins = gd.totalTrainingSeconds / 60
            ctx += " Total training: \(mins) minutes."
        }
        return ctx
    }

    init() {
        let welcomeDrill = MockData.drills[0]
        messages = [
            ChatMessage(
                role: .assistant,
                content: "I noticed your front-foot drive is a bit late. The transfer of weight is happening 0.2s after ball impact. Try this drill today to calibrate your timing.",
                drillAttachment: DrillAttachment.fromDrill(welcomeDrill),
                suggestedQuestions: ["Show me batting drills", "Analyze my technique", "How do I earn more V-Coins?"]
            )
        ]
    }

    func configure(with appState: AppState) {
        self.appState = appState
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        inputText = ""
        isLoading = true
        sessionMessageCount += 1
        showQuickActions = false

        Task {
            await fetchAIResponse(for: text)
        }
    }

    private func fetchAIResponse(for userText: String) async {
        let toolkitURL = Bundle.main.object(forInfoDictionaryKey: "EXPO_PUBLIC_TOOLKIT_URL") as? String ?? ""

        guard !toolkitURL.isEmpty else {
            appendSmartFallback(for: userText)
            isLoading = false
            awardSessionCoins()
            return
        }

        let url = URL(string: "\(toolkitURL)/agent/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var apiMessages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        for msg in messages {
            apiMessages.append(["role": msg.role.rawValue, "content": msg.content])
        }

        let body: [String: Any] = ["messages": apiMessages]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: request)

            if let responseString = parseStreamResponse(data) {
                let drill = matchDrillForResponse(userText: userText, aiResponse: responseString)
                let suggestions = generateSuggestions(from: responseString, userText: userText)
                let aiMessage = ChatMessage(
                    role: .assistant,
                    content: responseString,
                    drillAttachment: drill.map { DrillAttachment.fromDrill($0) },
                    suggestedQuestions: suggestions
                )
                messages.append(aiMessage)
                updateFocusTopic(from: responseString)
            } else {
                appendSmartFallback(for: userText)
            }
        } catch {
            let fallback = ChatMessage(
                role: .assistant,
                content: "I'm having trouble connecting right now. Let's focus on your technique \u{2014} what area would you like to work on?",
                suggestedQuestions: ["Batting tips", "Bowling practice", "Fielding drills"]
            )
            messages.append(fallback)
        }

        isLoading = false
        awardSessionCoins()
    }

    private func appendSmartFallback(for userText: String) {
        let response = getFallbackResponse(for: userText)
        let drill = matchDrillForResponse(userText: userText, aiResponse: response.text)
        let aiMessage = ChatMessage(
            role: .assistant,
            content: response.text,
            drillAttachment: drill.map { DrillAttachment.fromDrill($0) },
            suggestedQuestions: response.suggestions
        )
        messages.append(aiMessage)
        updateFocusTopic(from: response.text)
    }

    private func matchDrillForResponse(userText: String, aiResponse: String) -> Drill? {
        let combined = (userText + " " + aiResponse).lowercased()

        if combined.contains("batting") || combined.contains("bat") || combined.contains("drive") || combined.contains("shot") || combined.contains("front-foot") || combined.contains("front foot") || combined.contains("pull") {
            let battingDrills = MockData.drills.filter { $0.category == .batting || $0.category == .masterclass }
            if combined.contains("pull") || combined.contains("power") {
                return battingDrills.first(where: { $0.title.lowercased().contains("pull") || $0.title.lowercased().contains("power") }) ?? battingDrills.first
            }
            if combined.contains("spin") || combined.contains("wrist") {
                return MockData.drills.first(where: { $0.title.lowercased().contains("spin") })
            }
            if combined.contains("elbow") || combined.contains("follow") || combined.contains("drive") || combined.contains("front") {
                return MockData.drills.first(where: { $0.title.lowercased().contains("elbow") }) ?? battingDrills.first
            }
            return battingDrills.first
        }

        if combined.contains("bowling") || combined.contains("bowl") || combined.contains("yorker") || combined.contains("pace") || combined.contains("seam") {
            return MockData.drills.first(where: { $0.category == .bowling })
        }

        if combined.contains("fielding") || combined.contains("catch") || combined.contains("reflex") || combined.contains("field") {
            return MockData.drills.first(where: { $0.category == .fielding })
        }

        if combined.contains("wicketkeep") || combined.contains("keeper") || combined.contains("glove") {
            return MockData.drills.first(where: { $0.category == .wicketkeeping })
        }

        if combined.contains("drill") || combined.contains("train") || combined.contains("practice") || combined.contains("session") {
            let uncompleted = MockData.drills.filter { drill in
                !(appState?.gameData.completedDrillIDs.contains(drill.id.uuidString) ?? false)
            }
            return uncompleted.first ?? MockData.drills.randomElement()
        }

        return nil
    }

    private func generateSuggestions(from response: String, userText: String) -> [String] {
        let lower = response.lowercased()
        var suggestions: [String] = []

        if lower.contains("batting") || lower.contains("drive") || lower.contains("shot") {
            suggestions.append(contentsOf: ["Try a power hitting drill", "Show bowling drills"])
        } else if lower.contains("bowling") || lower.contains("yorker") {
            suggestions.append(contentsOf: ["Work on batting next", "Fielding practice"])
        } else if lower.contains("fielding") || lower.contains("catch") {
            suggestions.append(contentsOf: ["Back to batting", "Show my stats"])
        } else {
            suggestions.append(contentsOf: ["Show me a drill", "Analyze my game"])
        }

        suggestions.append("What should I focus on?")
        return Array(suggestions.prefix(3))
    }

    private func awardSessionCoins() {
        guard let appState else { return }
        if sessionMessageCount % 3 == 0 {
            appState.gameData.coachSessionCompleted()
            let reward = appState.gameData.isDoubleCoinWeekend ? 20 : 10
            appState.earnCoinsWithFeedback(reward, reason: "AI Coach Session")
        }
    }

    private func updateFocusTopic(from response: String) {
        let lower = response.lowercased()
        if lower.contains("front-foot") || lower.contains("front foot") || lower.contains("drive") {
            focusTopic = "Front-Foot Precision"
        } else if lower.contains("bowling") || lower.contains("yorker") || lower.contains("pace") {
            focusTopic = "Bowling Mastery"
        } else if lower.contains("fielding") || lower.contains("catch") || lower.contains("reflex") {
            focusTopic = "Fielding Excellence"
        } else if lower.contains("spin") || lower.contains("wrist") {
            focusTopic = "Spin Detection"
        } else if lower.contains("pull") || lower.contains("hook") || lower.contains("power") {
            focusTopic = "Power Hitting"
        } else if lower.contains("mental") || lower.contains("pressure") || lower.contains("focus") {
            focusTopic = "Mental Fortitude"
        } else if lower.contains("wicketkeep") || lower.contains("keeper") {
            focusTopic = "Wicketkeeping"
        }
    }

    private func parseStreamResponse(_ data: Data) -> String? {
        guard let raw = String(data: data, encoding: .utf8) else { return nil }

        var fullText = ""
        let lines = raw.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("0:\"") && trimmed.hasSuffix("\"") {
                let start = trimmed.index(trimmed.startIndex, offsetBy: 3)
                let end = trimmed.index(trimmed.endIndex, offsetBy: -1)
                let chunk = String(trimmed[start..<end])
                    .replacingOccurrences(of: "\\n", with: "\n")
                    .replacingOccurrences(of: "\\\"", with: "\"")
                fullText += chunk
            }
        }

        return fullText.isEmpty ? nil : fullText
    }

    private struct FallbackResponse {
        let text: String
        let suggestions: [String]
    }

    private func getFallbackResponse(for input: String) -> FallbackResponse {
        let lower = input.lowercased()

        if lower.contains("batting") || lower.contains("bat") || lower.contains("drive") || lower.contains("shot") {
            return FallbackResponse(
                text: "Great focus on batting! Your front-foot technique shows promise. Try the Weight Transfer Calibrator drill \u{2014} it'll help you get into position 0.15s faster. Head position over the front knee, let the bat flow through the line naturally.",
                suggestions: ["Try power hitting", "Show bowling drills", "Analyze my stats"]
            )
        }

        if lower.contains("bowling") || lower.contains("bowl") || lower.contains("yorker") {
            return FallbackResponse(
                text: "Bowling precision comes from a consistent run-up and release point. I recommend the Yorker Precision Training drill today. Focus on landing in the block-hole zone \u{2014} aim for 8/10 accuracy before moving to match-speed.",
                suggestions: ["Back to batting", "Fielding drills", "What's my rank?"]
            )
        }

        if lower.contains("fielding") || lower.contains("catch") || lower.contains("field") {
            return FallbackResponse(
                text: "Sharp fielding wins matches! The Reflex Catching Level 2 drill is perfect for you. Key focus: soft hands, watch the ball into your palms, and stay low through the catch. Let's get those reaction times down.",
                suggestions: ["Batting practice", "Show my stats", "Try wicketkeeping"]
            )
        }

        if lower.contains("spin") || lower.contains("wrist") {
            return FallbackResponse(
                text: "Spin detection is a game-changer. Watch the bowler's wrist position at release \u{2014} a flick outward means leg-spin, inward means off-spin. The Spin Detection Drill trains your eyes to read it 0.3s earlier. Start with slow deliveries and build up.",
                suggestions: ["More batting tips", "Try the drill now", "Power hitting"]
            )
        }

        if lower.contains("coin") || lower.contains("v-coin") || lower.contains("reward") || lower.contains("earn") {
            let coins = appState?.gameData.vCoins ?? 0
            return FallbackResponse(
                text: "You currently have \(coins) V-Coins! Earn more by completing drills, daily missions, recording matches, and chatting with me. Daily missions give 2x rewards. Weekend sessions earn double coins. Keep your streak alive for bonus multipliers!",
                suggestions: ["Start a drill", "Show store items", "What's my rank?"]
            )
        }

        if lower.contains("stat") || lower.contains("performance") || lower.contains("analyz") || lower.contains("progress") {
            let gd = appState?.gameData
            let drills = gd?.drillsCompleted ?? 0
            let streak = gd?.winStreak ?? 0
            let rank = gd?.globalRank ?? 999
            return FallbackResponse(
                text: "Here's your snapshot: \(drills) drills completed, \(streak)-day streak, ranked #\(rank) globally. \(streak > 5 ? "Incredible consistency!" : "Build that streak!") Your footwork against spin improved 22%. Focus on staying deeper in the crease for good-length balls.",
                suggestions: ["Show me a drill", "Batting tips", "How to improve rank?"]
            )
        }

        if lower.contains("rank") || lower.contains("leaderboard") || lower.contains("arena") {
            let rank = appState?.gameData.globalRank ?? 999
            return FallbackResponse(
                text: "You're currently ranked #\(rank) globally. To climb faster: complete daily missions for 2x coins, maintain your win streak, and focus on elite-level drills. Every completed drill improves your ranking score. The top 50 is within reach!",
                suggestions: ["Start a drill", "Daily mission", "Batting practice"]
            )
        }

        if lower.contains("pull") || lower.contains("hook") || lower.contains("power") {
            return FallbackResponse(
                text: "Power hitting is all about hip rotation and bat speed through the zone. The Power Pull Shot drill focuses on explosive movement. Key: get your front foot out of the way, rotate hard through the hips, and keep your head still. Let's build that six-hitting ability!",
                suggestions: ["Try the drill", "Front-foot work", "Show my stats"]
            )
        }

        let drills = appState?.gameData.drillsCompleted ?? 0
        if drills == 0 {
            return FallbackResponse(
                text: "Welcome to Vllow Dugout! I'm FR-03, your personal cricket coach. Let's start with a quick drill to assess your level. I recommend the Elbow Lock Mechanism \u{2014} it's our most popular masterclass. Tap the drill card above to get started!",
                suggestions: ["Show me batting drills", "Bowling practice", "How do V-Coins work?"]
            )
        }

        return FallbackResponse(
            text: "Based on your recent sessions, I'd recommend focusing on shot selection against spin. Your footwork has improved 22%, but there's room to be more decisive in the crease. Want me to break down a specific drill for this?",
            suggestions: ["Show me a drill", "Batting tips", "Analyze my game"]
        )
    }
}
