import SwiftUI

struct ArenaView: View {
    let appState: AppState
    @State private var selectedPeriod: LeaderboardPeriod = .weekly
    @State private var challengedPlayerIDs: Set<UUID> = []
    @State private var showChallengeFeedback = false

    private var entries: [LeaderboardEntry] {
        appState.gameData.leaderboard
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                periodFilter
                yourStatsBar
                topThreeSection
                fullLeaderboard
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.darkBg)
        .overlay(alignment: .top) {
            if showChallengeFeedback {
                challengeBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
            }
        }
    }

    private var periodFilter: some View {
        HStack(spacing: 8) {
            ForEach(LeaderboardPeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(.snappy) { selectedPeriod = period }
                } label: {
                    Text(period.rawValue.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(selectedPeriod == period ? .black : AppTheme.textSecondary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(selectedPeriod == period ? AppTheme.neonGreen : AppTheme.cardSurface)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(selectedPeriod == period ? .clear : AppTheme.border, lineWidth: 0.5)
                        )
                }
                .sensoryFeedback(.selection, trigger: selectedPeriod)
            }
            Spacer()
        }
    }

    private var yourStatsBar: some View {
        HStack(spacing: 16) {
            VStack(spacing: 2) {
                Text("YOUR RANK")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
                Text("#\(appState.globalRank)")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(AppTheme.neonGreen)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)

            Rectangle().fill(AppTheme.border).frame(width: 1, height: 30)

            VStack(spacing: 2) {
                Text("V-COINS")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
                Text(appState.vCoins.formatted())
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)

            Rectangle().fill(AppTheme.border).frame(width: 1, height: 30)

            VStack(spacing: 2) {
                Text("DRILLS")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
                Text("\(appState.drillsCompleted)")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
        }
        .padding(18)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.neonGreen.opacity(0.2), lineWidth: 1)
        )
    }

    private var topThreeSection: some View {
        let topThree = entries.prefix(3)
        return HStack(alignment: .bottom, spacing: 8) {
            if topThree.count >= 3 {
                podiumCard(entry: topThree[1], height: 140, medal: "2")
                podiumCard(entry: topThree[0], height: 170, medal: "1")
                podiumCard(entry: topThree[2], height: 120, medal: "3")
            }
        }
    }

    private func podiumCard(entry: LeaderboardEntry, height: CGFloat, medal: String) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(medal == "1" ? AppTheme.neonGreen.opacity(0.15) : AppTheme.cardSurfaceLight)
                    .frame(width: 52, height: 52)

                Text(entry.playerName.prefix(2).uppercased())
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(entry.isCurrentUser ? AppTheme.neonGreen : (medal == "1" ? AppTheme.neonGreen : AppTheme.textPrimary))
            }

            Text(entry.isCurrentUser ? "You" : entry.playerName)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(entry.isCurrentUser ? AppTheme.neonGreen : AppTheme.textPrimary)
                .lineLimit(1)

            Text("\(entry.vCoins.formatted()) V")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)

            Text(medal)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(medal == "1" ? AppTheme.neonGreen : AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: height * 0.35)
                .background(
                    medal == "1"
                    ? AppTheme.neonGreen.opacity(0.08)
                    : AppTheme.cardSurfaceLight
                )
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 12
                    )
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .background(entry.isCurrentUser ? AppTheme.neonGreen.opacity(0.06) : AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(entry.isCurrentUser ? AppTheme.neonGreen.opacity(0.4) : (medal == "1" ? AppTheme.neonGreen.opacity(0.3) : AppTheme.border), lineWidth: entry.isCurrentUser ? 1.5 : (medal == "1" ? 1 : 0.5))
        )
    }

    private var fullLeaderboard: some View {
        VStack(spacing: 0) {
            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                if index > 0 || entry.rank > 3 {
                    leaderboardRow(entry: entry)

                    if index < entries.count - 1 && entries[index].rank + 1 != entries[safe: index + 1]?.rank {
                        HStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { _ in
                                Circle()
                                    .fill(AppTheme.textTertiary)
                                    .frame(width: 3, height: 3)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                }
            }
        }
        .padding(4)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private func leaderboardRow(entry: LeaderboardEntry) -> some View {
        HStack(spacing: 14) {
            Text("#\(entry.rank)")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(entry.isCurrentUser ? AppTheme.neonGreen : AppTheme.textSecondary)
                .frame(width: 44, alignment: .leading)

            ZStack {
                Circle()
                    .fill(entry.isCurrentUser ? AppTheme.neonGreen.opacity(0.2) : AppTheme.cardSurfaceLight)
                    .frame(width: 36, height: 36)
                Text(entry.playerName.prefix(2).uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(entry.isCurrentUser ? AppTheme.neonGreen : AppTheme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.isCurrentUser ? "You" : entry.playerName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(entry.isCurrentUser ? AppTheme.neonGreen : AppTheme.textPrimary)
                Text("\(entry.drillsCompleted) drills")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Text("\(entry.vCoins.formatted()) V")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(AppTheme.textPrimary)

            if !entry.isCurrentUser && entry.rank > 3 {
                Button {
                    challengePlayer(entry)
                } label: {
                    Image(systemName: challengedPlayerIDs.contains(entry.id) ? "checkmark" : "bolt.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.black)
                        .frame(width: 32, height: 32)
                        .background(challengedPlayerIDs.contains(entry.id) ? AppTheme.neonGreen.opacity(0.5) : AppTheme.neonGreen)
                        .clipShape(Circle())
                }
                .disabled(challengedPlayerIDs.contains(entry.id))
                .sensoryFeedback(.impact(weight: .medium), trigger: challengedPlayerIDs.count)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(entry.isCurrentUser ? AppTheme.neonGreen.opacity(0.06) : .clear)
        .clipShape(.rect(cornerRadius: 14))
    }

    private func challengePlayer(_ entry: LeaderboardEntry) {
        challengedPlayerIDs.insert(entry.id)
        appState.earnCoinsWithFeedback(5, reason: "Challenge sent to \(entry.playerName)")
        withAnimation(.spring(response: 0.4)) {
            showChallengeFeedback = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { showChallengeFeedback = false }
        }
    }

    private var challengeBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "bolt.fill")
                .foregroundStyle(AppTheme.neonGreen)
            Text("Challenge Sent! +5 V-Coins")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .background(AppTheme.neonGreen.opacity(0.1))
        .clipShape(Capsule())
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
