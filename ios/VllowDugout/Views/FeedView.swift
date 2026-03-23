import SwiftUI

struct FeedView: View {
    let appState: AppState
    @State private var appeared = false
    @State private var showDrillSession = false
    @State private var showDailySession = false
    @State private var selectedDrill: Drill?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                morningPingSection
                skillTipCard
                dailyMissionCard
                statsGlimpse
                browseDrillsSection

                if appState.gameData.drillsCompleted > 0 {
                    recentActivitySection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.darkBg)
        .onAppear {
            withAnimation(.spring(response: 0.6)) { appeared = true }
        }
        .fullScreenCover(isPresented: $showDrillSession) {
            if let drill = selectedDrill {
                DrillSessionView(drill: drill, appState: appState)
            }
        }
        .fullScreenCover(isPresented: $showDailySession) {
            DrillSessionView(drill: appState.gameData.currentDailyDrill, appState: appState, isDailyMission: true)
        }
    }

    private var morningPingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(AppTheme.neonGreen)
                    .frame(width: 6, height: 6)
                    .shadow(color: AppTheme.neonGreen.opacity(0.6), radius: 4)

                Text("LIVE FROM THE COACH")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(greetingMessage)
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineSpacing(2)

                Text(motivationalSubtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.cardSurface)
            .clipShape(.rect(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppTheme.border, lineWidth: 0.5)
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let streak = appState.winStreak
        if streak > 7 {
            return hour < 12 ? "Morning, legend.\n\(streak)-day streak!" : "Keep grinding.\n\(streak) days strong!"
        } else if streak > 0 {
            return hour < 12 ? "Wake up, champ.\nDay \(streak + 1) awaits." : "Let's go, champ.\nTime to grind."
        } else {
            return hour < 12 ? "Wake up, champ.\nTime to grind." : "The pitch is calling.\nLet's train."
        }
    }

    private var motivationalSubtitle: String {
        let completed = appState.drillsCompleted
        if completed == 0 {
            return "Complete your first drill to start earning V-Coins!"
        } else if completed < 10 {
            return "\(completed) drills done. The pitch is waiting for its next master."
        } else {
            return "\(completed) drills crushed. Elite status incoming."
        }
    }

    private var skillTipCard: some View {
        let drill = MockData.drills[0]
        return VStack(spacing: 0) {
            Color(AppTheme.cardSurface)
                .aspectRatio(4/5, contentMode: .fit)
                .overlay {
                    AsyncImage(url: URL(string: drill.imageURL)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            AppTheme.cardSurface
                        }
                    }
                    .allowsHitTesting(false)
                }
                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.2),
                            .init(color: .black.opacity(0.85), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .clipShape(.rect(cornerRadius: 20))
                .overlay(alignment: .topLeading) {
                    Text(drill.category.rawValue.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.15))
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(16)
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        appState.toggleBookmark(for: drill.id)
                    } label: {
                        Image(systemName: appState.isBookmarked(drill.id) ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(appState.isBookmarked(drill.id) ? AppTheme.neonGreen : .white)
                            .frame(width: 40, height: 40)
                            .background(.white.opacity(0.1))
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .sensoryFeedback(.impact(weight: .light), trigger: appState.gameData.bookmarkedDrillIDs.count)
                    .padding(16)
                }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(drill.title)
                            .font(.system(size: 26, weight: .black))
                            .foregroundStyle(.white)

                        Text(drill.subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(2)

                        HStack(spacing: 16) {
                            Button {
                                selectedDrill = drill
                                showDrillSession = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 14))
                                    Text(appState.gameData.completedDrillIDs.contains(drill.id.uuidString) ? "REDO DRILL" : "WATCH DRILL")
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(1)
                                }
                                .foregroundStyle(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(AppTheme.neonGreen)
                                .clipShape(Capsule())
                            }

                            Text(drill.durationFormatted)
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .padding(.top, 4)
                    }
                    .padding(20)
                }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.1), value: appeared)
    }

    private var dailyMissionCard: some View {
        let drill = appState.gameData.currentDailyDrill
        let completed = appState.gameData.isDailyMissionCompleted
        return VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DAILY MISSION")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(AppTheme.textSecondary)

                    Text(drill.title)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(AppTheme.goldAccent)
                    Text("+\(drill.coinReward * 2)")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.cardSurfaceLight)
                .clipShape(.rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.border, lineWidth: 0.5)
                )
            }

            HStack(spacing: 10) {
                statPill(label: "TARGET", value: "\(drill.targetHits) Hits")
                statPill(label: "TIME", value: "\(drill.durationSeconds)s")
                statPill(label: "DIFFICULTY", value: drill.difficulty.rawValue)
            }

            Button {
                if !completed {
                    showDailySession = true
                }
            } label: {
                HStack(spacing: 10) {
                    if completed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.neonGreen)
                        Text("MISSION COMPLETE")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(AppTheme.neonGreen)
                    } else {
                        Text("START TRACKING SESSION")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(0.5)
                        Image(systemName: "sensor.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.neonGreen)
                    }
                }
                .foregroundStyle(completed ? AppTheme.neonGreen : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(completed ? AppTheme.neonGreen.opacity(0.1) : Color.white.opacity(0.1))
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(completed ? AppTheme.neonGreen.opacity(0.3) : AppTheme.border, lineWidth: 0.5)
                )
            }
            .disabled(completed)
            .sensoryFeedback(.impact(weight: .heavy), trigger: showDailySession)
        }
        .padding(24)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.2), value: appeared)
    }

    private func statPill(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .tracking(2)
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppTheme.darkBg)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var statsGlimpse: some View {
        HStack(spacing: 12) {
            Button {
                appState.selectedTab = .intel
            } label: {
                statCard(
                    icon: "arrow.up.right",
                    iconBg: AppTheme.neonGreenDim,
                    label: "WIN STREAK",
                    value: "\(appState.winStreak) DAYS"
                )
            }
            .buttonStyle(.plain)

            Button {
                appState.selectedTab = .arena
            } label: {
                statCard(
                    icon: "medal.fill",
                    iconBg: Color.orange.opacity(0.15),
                    label: "GLOBAL RANK",
                    value: "#\(appState.globalRank)"
                )
            }
            .buttonStyle(.plain)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.3), value: appeared)
    }

    private var browseDrillsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("MORE DRILLS")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer()
                Text("\(appState.gameData.completedDrillIDs.count)/\(MockData.drills.count) DONE")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(AppTheme.neonGreen)
            }

            ForEach(MockData.drills.dropFirst()) { drill in
                let completed = appState.gameData.completedDrillIDs.contains(drill.id.uuidString)
                Button {
                    selectedDrill = drill
                    showDrillSession = true
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(completed ? AppTheme.neonGreen.opacity(0.15) : AppTheme.cardSurfaceLight)
                                .frame(width: 44, height: 44)
                            Image(systemName: completed ? "checkmark" : "play.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(completed ? AppTheme.neonGreen : AppTheme.textPrimary)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(drill.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppTheme.textPrimary)
                                .lineLimit(1)
                            HStack(spacing: 8) {
                                Text(drill.category.rawValue.uppercased())
                                    .font(.system(size: 9, weight: .bold))
                                    .tracking(1)
                                    .foregroundStyle(AppTheme.textTertiary)
                                Text("•")
                                    .foregroundStyle(AppTheme.textTertiary)
                                Text(drill.difficulty.rawValue)
                                    .font(.system(size: 9, weight: .bold))
                                    .tracking(1)
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(AppTheme.goldAccent)
                                Text("+\(drill.coinReward)")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(AppTheme.textPrimary)
                            }
                            Text(drill.durationFormatted)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(completed ? AppTheme.neonGreen.opacity(0.04) : AppTheme.cardSurfaceLight.opacity(0.5))
                    .clipShape(.rect(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.35), value: appeared)
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("RECENT ACTIVITY")
                .font(.system(size: 9, weight: .bold))
                .tracking(3)
                .foregroundStyle(AppTheme.textSecondary)

            let transactions = appState.gameData.loadTransactions().suffix(5).reversed()
            ForEach(Array(transactions), id: \.id) { tx in
                HStack {
                    Circle()
                        .fill(AppTheme.neonGreen.opacity(0.15))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(AppTheme.neonGreen)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tx.reason)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(1)
                        Text(tx.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(AppTheme.textTertiary)
                    }

                    Spacer()

                    Text("+\(tx.amount)")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(AppTheme.neonGreen)
                }
                .padding(.vertical, 6)
            }
        }
        .padding(20)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.4), value: appeared)
    }

    private func statCard(icon: String, iconBg: Color, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(width: 40, height: 40)
                .background(iconBg)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
                Text(value)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
                    .contentTransition(.numericText())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }
}
