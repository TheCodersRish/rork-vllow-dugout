import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage: Int = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "cricket.ball.fill",
            title: "Train Like\nThe Elite",
            subtitle: "AI-powered drills tailored to your skill level. Every session pushes you closer to greatness.",
            accentIcon: "bolt.fill"
        ),
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Your Personal\nAI Coach",
            subtitle: "Get real-time feedback on your technique, strategy insights, and personalized training plans.",
            accentIcon: "waveform"
        ),
        OnboardingPage(
            icon: "trophy.fill",
            title: "Compete &\nEarn Rewards",
            subtitle: "Climb the global leaderboard, earn V-Coins, and unlock premium gear in the Pro Store.",
            accentIcon: "star.fill"
        )
    ]

    var body: some View {
        ZStack {
            AppTheme.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageContent(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                Spacer()

                pageIndicator
                    .padding(.bottom, 32)

                actionButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                if currentPage < pages.count - 1 {
                    Button {
                        withAnimation { onComplete() }
                    } label: {
                        Text("Skip")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .padding(.bottom, 24)
                } else {
                    Color.clear.frame(height: 48)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func pageContent(_ page: OnboardingPage) -> some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(AppTheme.neonGreenDim)
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(AppTheme.cardSurface)
                    .frame(width: 110, height: 110)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.neonGreen.opacity(0.3), lineWidth: 1)
                    )

                Image(systemName: page.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(AppTheme.neonGreen)
                    .symbolEffect(.pulse, options: .repeating)
            }

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 34, weight: .black))
                    .tracking(-0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(page.subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, 24)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? AppTheme.neonGreen : AppTheme.textTertiary)
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    private var actionButton: some View {
        Button {
            if currentPage < pages.count - 1 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentPage += 1
                }
            } else {
                withAnimation { onComplete() }
            }
        } label: {
            HStack(spacing: 10) {
                Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                    .font(.system(size: 17, weight: .bold))

                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(Color(red: 0.07, green: 0.07, blue: 0.06))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(AppTheme.neonGreen)
            .clipShape(.rect(cornerRadius: 29))
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: currentPage)
    }
}

nonisolated struct OnboardingPage: Sendable {
    let icon: String
    let title: String
    let subtitle: String
    let accentIcon: String
}
