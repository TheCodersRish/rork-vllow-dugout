import SwiftUI
import HealthKit

struct ProfileView: View {
    let authViewModel: AuthViewModel
    let appState: AppState
    @State private var healthService = HealthKitService()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    statsOverview
                    healthSection
                    integrationsSection
                    dangerZone
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(AppTheme.darkBg)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(AppTheme.cardSurfaceLight)
                .frame(width: 80, height: 80)
                .overlay(
                    Text(userInitial)
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(AppTheme.neonGreen)
                )
                .overlay(
                    Circle()
                        .stroke(AppTheme.neonGreen.opacity(0.5), lineWidth: 2)
                )

            VStack(spacing: 4) {
                Text(authViewModel.currentUser?.name ?? "Champion")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(authViewModel.currentUser?.email ?? "")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.goldAccent)
                Text("\(appState.gameData.vCoins.formatted()) V-COINS")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AppTheme.cardSurface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AppTheme.border, lineWidth: 0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "YOUR STATS", icon: "chart.bar.fill")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard(label: "Drills Done", value: "\(appState.gameData.drillsCompleted)", icon: "flame.fill", iconColor: .orange)
                statCard(label: "Win Streak", value: "\(appState.gameData.winStreak) Days", icon: "bolt.fill", iconColor: AppTheme.neonGreen)
                statCard(label: "Global Rank", value: "#\(appState.gameData.globalRank)", icon: "trophy.fill", iconColor: AppTheme.goldAccent)
                statCard(label: "Training", value: trainingTime, icon: "timer", iconColor: .cyan)
            }
        }
    }

    private var healthSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "APPLE HEALTH", icon: "heart.fill")

            if healthService.isAuthorized {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        healthMetric(icon: "figure.walk", label: "Steps", value: "\(healthService.stepCount.formatted())", color: .green)
                        healthMetric(icon: "flame.fill", label: "Calories", value: "\(healthService.activeCalories)", color: .orange)
                        healthMetric(icon: "heart.fill", label: "Heart Rate", value: healthService.heartRate > 0 ? "\(healthService.heartRate) bpm" : "—", color: .red)
                    }

                    Button {
                        Task { await healthService.fetchHealthData() }
                    } label: {
                        HStack(spacing: 8) {
                            if healthService.isLoading {
                                ProgressView()
                                    .tint(AppTheme.textSecondary)
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text("Refresh Data")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppTheme.cardSurfaceLight)
                        .clipShape(.rect(cornerRadius: 10))
                    }
                    .disabled(healthService.isLoading)

                    Button {
                        healthService.disconnect()
                    } label: {
                        Text("Disconnect Apple Health")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.red.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(.red.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 10))
                    }
                }
                .padding(16)
                .background(AppTheme.cardSurface)
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.border, lineWidth: 0.5)
                )
            } else {
                Button {
                    Task { await healthService.requestAuthorization() }
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.red, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                            Image(systemName: "heart.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Link Apple Health")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Sync steps, calories & heart rate")
                                .font(.system(size: 12))
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(AppTheme.neonGreen)
                    }
                    .padding(16)
                    .background(AppTheme.cardSurface)
                    .clipShape(.rect(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.border, lineWidth: 0.5)
                    )
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: healthService.isAuthorized)
            }
        }
    }

    private var integrationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "INTEGRATIONS", icon: "link")

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.cardSurfaceLight)
                        .frame(width: 44, height: 44)
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Cric Clubs")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Match data sync & club management")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                Text("SOON")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(AppTheme.neonGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.neonGreen.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(16)
            .background(AppTheme.cardSurface)
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.border, lineWidth: 0.5)
            )
        }
    }

    private var dangerZone: some View {
        Button {
            authViewModel.signOut()
            dismiss()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.red.opacity(0.08))
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.red.opacity(0.15), lineWidth: 0.5)
            )
        }
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.neonGreen)
            Text(title)
                .font(.system(size: 11, weight: .heavy))
                .tracking(1.5)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private func statCard(label: String, value: String, icon: String, iconColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Circle()
                .fill(iconColor.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundStyle(iconColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(AppTheme.textSecondary)
                Text(value)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private func healthMetric(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label.uppercased())
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppTheme.cardSurfaceLight)
        .clipShape(.rect(cornerRadius: 12))
    }

    private var userInitial: String {
        if let name = authViewModel.currentUser?.name, let first = name.first {
            return String(first).uppercased()
        }
        if let email = authViewModel.currentUser?.email, let first = email.first {
            return String(first).uppercased()
        }
        return "V"
    }

    private var trainingTime: String {
        let minutes = appState.gameData.totalTrainingSeconds / 60
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
        return "\(minutes)m"
    }
}
