import SwiftUI
import SwiftData

struct ContentView: View {
    @Bindable var authViewModel: AuthViewModel
    @State private var appState = AppState()
    @State private var showSignOutConfirmation = false
    @State private var showProfile = false
    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .ignoresSafeArea(.keyboard)

            floatingTabBar
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .preferredColorScheme(.dark)
        .overlay(alignment: .top) {
            if appState.showCoinEarned {
                coinEarnedBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4), value: appState.showCoinEarned)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch appState.selectedTab {
        case .feed:
            feedTab
        case .coach:
            coachTab
        case .intel:
            intelTab
        case .arena:
            arenaTab
        case .store:
            storeTab
        }
    }

    private var feedTab: some View {
        VStack(spacing: 0) {
            topBar
            FeedView(appState: appState)
        }
        .background(AppTheme.darkBg)
    }

    private var coachTab: some View {
        VStack(spacing: 0) {
            topBar
            CoachView(appState: appState)
        }
        .background(AppTheme.darkBg)
    }

    private var intelTab: some View {
        VStack(spacing: 0) {
            topBar
            IntelView(appState: appState)
        }
        .background(AppTheme.darkBg)
    }

    private var arenaTab: some View {
        VStack(spacing: 0) {
            topBar
            ArenaView(appState: appState)
        }
        .background(AppTheme.darkBg)
    }

    private var storeTab: some View {
        VStack(spacing: 0) {
            topBar
            StoreView(appState: appState)
        }
        .background(AppTheme.darkBg)
    }

    private var topBar: some View {
        HStack {
            HStack(spacing: 10) {
                Button {
                    showProfile = true
                } label: {
                    Circle()
                        .fill(AppTheme.cardSurfaceLight)
                        .frame(width: 38, height: 38)
                        .overlay(
                            Text(userInitial)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(AppTheme.neonGreen)
                        )
                        .overlay(
                            Circle()
                                .stroke(AppTheme.neonGreen.opacity(0.4), lineWidth: 1.5)
                        )
                }
                .sheet(isPresented: $showProfile) {
                    ProfileView(authViewModel: authViewModel, appState: appState)
                }

                Text("Vllow Dugout")
                    .font(.system(size: 18, weight: .black))
                    .tracking(-0.3)
                    .foregroundStyle(AppTheme.textPrimary)
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(AppTheme.goldAccent)

                Text("\(appState.gameData.vCoins.formatted()) V-COINS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(AppTheme.textPrimary)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(AppTheme.cardSurface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.border, lineWidth: 0.5)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppTheme.darkBg.opacity(0.9))
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

    private var coinEarnedBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .foregroundStyle(AppTheme.goldAccent)
            Text(appState.lastCoinReason.isEmpty ? "V-Coins Earned!" : appState.lastCoinReason)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .background(AppTheme.neonGreen.opacity(0.15))
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(AppTheme.neonGreen.opacity(0.3), lineWidth: 0.5)
        )
        .padding(.top, 60)
        .shadow(color: AppTheme.neonGreen.opacity(0.2), radius: 10, y: 4)
    }

    private var floatingTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        appState.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20))
                            .symbolVariant(appState.selectedTab == tab ? .fill : .none)
                            .contentTransition(.symbolEffect(.replace))

                        Text(tab.title.uppercased())
                            .font(.system(size: 8, weight: .bold))
                            .tracking(1)
                    }
                    .foregroundStyle(appState.selectedTab == tab ? AppTheme.textPrimary : AppTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .sensoryFeedback(.selection, trigger: appState.selectedTab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .background(AppTheme.cardSurface.opacity(0.7))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}

#Preview {
    ContentView(authViewModel: AuthViewModel())
        .modelContainer(for: UserProfile.self, inMemory: true)
}
