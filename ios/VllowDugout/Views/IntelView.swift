import SwiftUI

struct IntelView: View {
    let appState: AppState
    @State private var showMatchRecorder = false

    private var gameData: GameDataService { appState.gameData }
    private let zones = MockData.scoringZones
    private let dismissals = MockData.dismissalPatterns

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let match = gameData.latestMatch {
                    heroSummary(match)
                } else {
                    emptyHero
                }
                heatMapSection
                dismissalSection
                aiInsightStrip

                if gameData.matchHistory.count > 1 {
                    matchHistorySection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.darkBg)
        .fullScreenCover(isPresented: $showMatchRecorder) {
            MatchRecorderView(appState: appState)
        }
    }

    private var emptyHero: some View {
        VStack(spacing: 20) {
            Image(systemName: "cricket.ball.fill")
                .font(.system(size: 40))
                .foregroundStyle(AppTheme.textTertiary)

            Text("No Matches Yet")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Record your first match to see performance analytics")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                showMatchRecorder = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("RECORD MATCH")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1)
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(AppTheme.neonGreen)
                .clipShape(Capsule())
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: showMatchRecorder)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private func heroSummary(_ match: MatchRecord) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("LATEST PERFORMANCE")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(AppTheme.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(match.runs)")
                            .font(.system(size: 56, weight: .black))
                            .foregroundStyle(AppTheme.textPrimary)
                            .contentTransition(.numericText())
                        Text("off \(match.ballsFaced)")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    HStack(spacing: 12) {
                        let srChange = gameData.matchHistory.count > 1
                            ? match.strikeRate - gameData.matchHistory[1].strikeRate
                            : match.strikeRate

                        HStack(spacing: 4) {
                            Image(systemName: srChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 11, weight: .bold))
                            Text(String(format: "%+.0f%% SR", srChange))
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundStyle(srChange >= 0 ? AppTheme.neonGreen : .red)

                        Rectangle()
                            .fill(AppTheme.border)
                            .frame(width: 1, height: 12)

                        Text("vs \(match.opponent)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                Spacer()

                VStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppTheme.neonGreen)
                    Text("+\(match.coinBonus) V COINS")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("MATCH BONUS")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(18)
                .background(AppTheme.cardSurfaceLight)
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.border, lineWidth: 0.5)
                )
            }

            Button {
                showMatchRecorder = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                    Text("RECORD NEW MATCH")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1)
                }
                .foregroundStyle(AppTheme.neonGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.neonGreen.opacity(0.08))
                .clipShape(.rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.neonGreen.opacity(0.2), lineWidth: 0.5)
                )
            }
            .sensoryFeedback(.impact(weight: .light), trigger: showMatchRecorder)
            .padding(.top, 16)
        }
        .padding(24)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private var heatMapSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(AppTheme.neonGreen)
                        .frame(width: 3, height: 18)
                        .clipShape(.rect(cornerRadius: 2))
                    Text("Run Scoring Zone Heat Map")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                }

                Spacer()

                Text("FULL 360°")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.cardSurfaceLight)
                    .clipShape(Capsule())
            }

            ZStack {
                Color(AppTheme.cardSurfaceLight)
                    .aspectRatio(1.4, contentMode: .fit)
                    .clipShape(.rect(cornerRadius: 14))

                Ellipse()
                    .stroke(AppTheme.border, lineWidth: 1)
                    .padding(20)

                Rectangle()
                    .fill(AppTheme.border)
                    .frame(width: 16, height: 3)

                ForEach(zones) { zone in
                    let dynamicIntensity = gameData.totalRuns > 0
                        ? zone.intensity * min(Double(gameData.totalRuns) / 100.0, 1.0) + 0.2
                        : zone.intensity * 0.3

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppTheme.neonGreen.opacity(dynamicIntensity * 0.6), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .position(
                            x: zone.xPosition * 300,
                            y: zone.yPosition * 200
                        )
                }

                VStack(spacing: 2) {
                    Text(zones[0].name.uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("\(dynamicRuns(for: zones[0])) RUNS")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .background(AppTheme.cardSurface.opacity(0.8))
                .clipShape(.rect(cornerRadius: 10))
                .position(x: 80, y: 50)

                VStack(spacing: 2) {
                    Text(zones[1].name.uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("\(dynamicRuns(for: zones[1])) RUNS")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .background(AppTheme.cardSurface.opacity(0.8))
                .clipShape(.rect(cornerRadius: 10))
                .position(x: 250, y: 170)
            }
            .frame(height: 220)
            .clipShape(.rect(cornerRadius: 14))

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Circle().fill(AppTheme.neonGreen).frame(width: 6, height: 6)
                    Text("HOT ZONE")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                HStack(spacing: 6) {
                    Circle().fill(AppTheme.neonGreen.opacity(0.3)).frame(width: 6, height: 6)
                    Text("ACTIVE")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .padding(20)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private func dynamicRuns(for zone: ScoringZone) -> Int {
        guard gameData.totalRuns > 0 else { return zone.runs }
        let factor = Double(gameData.totalRuns) / 67.0
        return max(1, Int(Double(zone.runs) * factor))
    }

    private var dismissalSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(AppTheme.textSecondary)
                    .frame(width: 3, height: 18)
                    .clipShape(.rect(cornerRadius: 2))
                Text("Dismissal Pattern")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
            }

            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(AppTheme.cardSurfaceLight, lineWidth: 10)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: 0.45)
                        .stroke(AppTheme.neonGreen, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("PRIMARY")
                            .font(.system(size: 7, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(AppTheme.textTertiary)
                        Text("CAUGHT")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }

                VStack(spacing: 8) {
                    ForEach(dismissals) { pattern in
                        HStack {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(pattern.type == "Caught" ? AppTheme.neonGreen : AppTheme.border)
                                    .frame(width: 6, height: 6)
                                Text(pattern.type)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            Spacer()
                            Text("\(Int(pattern.percentage))%")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(pattern.type == "Caught" ? AppTheme.cardSurfaceLight : AppTheme.darkBg)
                        .clipShape(.rect(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(20)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private var aiInsightStrip: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 20))
                .foregroundStyle(AppTheme.neonGreen)
                .frame(width: 44, height: 44)
                .background(AppTheme.cardSurface)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(AppTheme.neonGreen.opacity(0.3), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text("PERFORMANCE INTEL")
                    .font(.system(size: 10, weight: .black))
                    .tracking(2)
                    .foregroundStyle(AppTheme.neonGreen)

                Text(dynamicInsight)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(3)
            }
        }
        .padding(20)
        .background(AppTheme.neonGreen.opacity(0.05))
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.neonGreen.opacity(0.15), lineWidth: 1)
        )
    }

    private var dynamicInsight: String {
        let matches = gameData.matchHistory.count
        let drills = gameData.drillsCompleted
        let avgSR = gameData.averageStrikeRate

        if matches == 0 && drills == 0 {
            return "Welcome to Vllow Dugout! Start by completing drills and recording matches to get personalized performance insights from your AI coach."
        } else if matches == 0 {
            return "You've completed **\(drills) drills** so far — great dedication! Record your first match to unlock detailed batting analytics and scoring zone breakdowns."
        } else if avgSR > 140 {
            return "Incredible strike rate of **\(String(format: "%.0f", avgSR))**! Your aggressive approach is paying off. Watch your shot selection after the 30th delivery — the **Caught at Deep Mid-Wicket** risk increases with fatigue."
        } else if avgSR > 100 {
            return "Solid batting with **\(String(format: "%.0f", avgSR))** average strike rate across \(matches) matches. Focus on rotating the strike more in the middle overs. Your footwork against spin has room for improvement."
        } else {
            return "Your average strike rate is **\(String(format: "%.0f", avgSR))** across \(matches) matches. Consider working on power hitting drills to improve run rate. The **Pull Shot** and **Spin Detection** drills are recommended."
        }
    }

    private var matchHistorySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(AppTheme.goldAccent)
                    .frame(width: 3, height: 18)
                    .clipShape(.rect(cornerRadius: 2))
                Text("Match History")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Text("\(gameData.matchHistory.count) MATCHES")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ForEach(gameData.matchHistory.prefix(5)) { match in
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 4) {
                            Text("\(match.runs)")
                                .font(.system(size: 20, weight: .black))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("(\(match.ballsFaced))")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        Text("vs \(match.opponent)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textTertiary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text("SR \(String(format: "%.1f", match.strikeRate))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(match.strikeRate > 120 ? AppTheme.neonGreen : AppTheme.textSecondary)
                        Text("+\(match.coinBonus) V")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppTheme.goldAccent)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(AppTheme.cardSurfaceLight.opacity(0.5))
                .clipShape(.rect(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }
}
