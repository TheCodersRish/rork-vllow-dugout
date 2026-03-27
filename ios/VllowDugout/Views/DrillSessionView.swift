import SwiftUI

struct DrillSessionView: View {
    let drill: Drill
    let appState: AppState
    let isDailyMission: Bool
    @Environment(\.dismiss) private var dismiss

    @State private var timeRemaining: Int
    @State private var isActive: Bool = false
    @State private var isCompleted: Bool = false
    @State private var hitsLanded: Int = 0
    @State private var coinsEarned: Int = 0
    @State private var currentTipIndex: Int = 0
    @State private var showCountdown: Bool = false
    @State private var countdownValue: Int = 3

    init(drill: Drill, appState: AppState, isDailyMission: Bool = false) {
        self.drill = drill
        self.appState = appState
        self.isDailyMission = isDailyMission
        self._timeRemaining = State(initialValue: drill.durationSeconds)
    }

    private var tips: [DrillTip] {
        DrillTip.tips(for: drill.category)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer()
            if isCompleted {
                completionView
            } else if showCountdown {
                countdownView
            } else if isActive {
                activeSessionContent
            } else {
                preSessionContent
            }
            Spacer()
            bottomAction
        }
        .padding(24)
        .background(AppTheme.darkBg)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.cardSurface)
                    .clipShape(Circle())
            }
            Spacer()
            if isDailyMission {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.goldAccent)
                    Text("DAILY MISSION")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppTheme.goldAccent)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.goldAccent.opacity(0.15))
                .clipShape(Capsule())
            } else {
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.neonGreen)
                        .frame(width: 5, height: 5)
                    Text(drill.category.rawValue.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.cardSurface)
                .clipShape(Capsule())
            }
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
    }

    private var preSessionContent: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text(drill.title)
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                Text(drill.subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 8)
            }

            ZStack {
                Circle()
                    .stroke(AppTheme.cardSurfaceLight, lineWidth: 10)
                    .frame(width: 180, height: 180)

                VStack(spacing: 4) {
                    Text(timeFormatted)
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                        .monospacedDigit()
                    Text("READY")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            HStack(spacing: 12) {
                sessionStat(label: "HITS", value: "\(drill.targetHits)")
                sessionStat(label: "TIME", value: drill.durationFormatted)
                sessionStat(label: "REWARD", value: "+\(isDailyMission ? drill.coinReward * 2 : drill.coinReward)")
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.neonGreen)
                    Text("COACH TIP")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppTheme.neonGreen)
                }

                Text(tips.first?.text ?? "Focus on your technique and keep your eye on the ball.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineSpacing(3)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.neonGreen.opacity(0.06))
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.neonGreen.opacity(0.15), lineWidth: 0.5)
            )
        }
    }

    private var countdownView: some View {
        VStack(spacing: 20) {
            Text(drill.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)

            ZStack {
                Circle()
                    .fill(AppTheme.neonGreen.opacity(0.1))
                    .frame(width: 180, height: 180)
                Circle()
                    .stroke(AppTheme.neonGreen, lineWidth: 6)
                    .frame(width: 180, height: 180)
                Text("\(countdownValue)")
                    .font(.system(size: 72, weight: .black))
                    .foregroundStyle(AppTheme.neonGreen)
                    .contentTransition(.numericText())
            }

            Text("GET READY")
                .font(.system(size: 12, weight: .bold))
                .tracking(4)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var activeSessionContent: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text(drill.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                Text("SESSION IN PROGRESS")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(AppTheme.neonGreen)
            }

            ZStack {
                Circle()
                    .stroke(AppTheme.cardSurfaceLight, lineWidth: 10)
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AppTheme.neonGreen,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                VStack(spacing: 4) {
                    Text(timeFormatted)
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    Text("\(hitsLanded)/\(drill.targetHits) HITS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AppTheme.neonGreen)
                }
            }

            if !tips.isEmpty {
                let tip = tips[currentTipIndex % tips.count]
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: tip.icon)
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.neonGreen)
                        Text("STEP \(currentTipIndex + 1)/\(tips.count)")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(AppTheme.neonGreen)
                    }

                    Text(tip.text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .contentTransition(.opacity)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.neonGreen.opacity(0.06))
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.neonGreen.opacity(0.15), lineWidth: 0.5)
                )
                .animation(.easeInOut(duration: 0.3), value: currentTipIndex)
            }

            HStack(spacing: 12) {
                sessionStat(label: "HITS", value: "\(hitsLanded)/\(drill.targetHits)")
                sessionStat(label: "DIFFICULTY", value: drill.difficulty.rawValue)
                sessionStat(label: "REWARD", value: "+\(isDailyMission ? drill.coinReward * 2 : drill.coinReward)")
            }
        }
    }

    private func sessionStat(label: String, value: String) -> some View {
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
        .padding(.vertical, 12)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(AppTheme.neonGreen.opacity(0.15))
                    .frame(width: 140, height: 140)
                Circle()
                    .fill(AppTheme.cardSurface)
                    .frame(width: 110, height: 110)
                Image(systemName: "checkmark")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(AppTheme.neonGreen)
            }

            Text("Session Complete!")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(AppTheme.textPrimary)

            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundStyle(AppTheme.goldAccent)
                Text("+\(coinsEarned) V-COINS EARNED")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(AppTheme.goldAccent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.goldAccent.opacity(0.12))
            .clipShape(Capsule())

            HStack(spacing: 12) {
                sessionStat(label: "HITS", value: "\(hitsLanded)")
                sessionStat(label: "TIME", value: drill.durationFormatted)
                sessionStat(label: "DRILLS TOTAL", value: "\(appState.drillsCompleted)")
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.neonGreen)
                    Text("POST-SESSION INSIGHT")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppTheme.neonGreen)
                }

                Text(completionInsight)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineSpacing(3)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.neonGreen.opacity(0.06))
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.neonGreen.opacity(0.15), lineWidth: 0.5)
            )
        }
    }

    private var completionInsight: String {
        let hitRate = drill.targetHits > 0 ? Double(hitsLanded) / Double(drill.targetHits) * 100 : 0
        if hitRate >= 100 {
            return "Outstanding! You hit every target. Your \(drill.category.rawValue.lowercased()) skills are progressing fast. Try increasing the difficulty next time."
        } else if hitRate >= 70 {
            return "Solid performance at \(Int(hitRate))% accuracy! Focus on timing and consistency to push for 100%. Your \(drill.category.rawValue.lowercased()) is improving."
        } else if hitRate >= 40 {
            return "\(Int(hitRate))% accuracy \u{2014} room to grow. Slow down and focus on form over speed. Repeat this drill tomorrow to build muscle memory."
        } else {
            return "Keep at it! Every rep counts. Focus on the basics: body position, eye on the ball, and smooth follow-through. You'll see improvement fast."
        }
    }

    private var bottomAction: some View {
        Group {
            if isCompleted {
                Button {
                    dismiss()
                } label: {
                    Text("BACK TO FEED")
                        .font(.system(size: 15, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.neonGreen)
                        .clipShape(.rect(cornerRadius: 20))
                }
                .sensoryFeedback(.impact(weight: .medium), trigger: isCompleted)
            } else if isActive {
                Button {
                    tapHit()
                } label: {
                    VStack(spacing: 6) {
                        Text("TAP TO HIT")
                            .font(.system(size: 17, weight: .black))
                            .tracking(1)
                        Text("Tap each time you complete a rep")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.black.opacity(0.6))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
                    .background(AppTheme.neonGreen)
                    .clipShape(.rect(cornerRadius: 20))
                }
                .sensoryFeedback(.impact(weight: .heavy), trigger: hitsLanded)
            } else if showCountdown {
                Color.clear.frame(height: 60)
            } else {
                Button {
                    beginCountdown()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16))
                        Text("START SESSION")
                            .font(.system(size: 15, weight: .bold))
                            .tracking(1)
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppTheme.neonGreen)
                    .clipShape(.rect(cornerRadius: 20))
                }
            }
        }
    }

    private var progress: Double {
        guard drill.durationSeconds > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(drill.durationSeconds))
    }

    private var timeFormatted: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%d:%02d", m, s)
    }

    private func beginCountdown() {
        showCountdown = true
        countdownValue = 3
        Task {
            for i in stride(from: 3, through: 1, by: -1) {
                withAnimation(.spring(response: 0.3)) {
                    countdownValue = i
                }
                try? await Task.sleep(for: .seconds(1))
            }
            withAnimation(.spring(response: 0.4)) {
                showCountdown = false
                isActive = true
            }
            runTimer()
        }
    }

    private func runTimer() {
        Task {
            while timeRemaining > 0 && isActive && !isCompleted {
                try? await Task.sleep(for: .seconds(1))
                guard isActive, !isCompleted else { break }
                withAnimation { timeRemaining -= 1 }

                let elapsed = drill.durationSeconds - timeRemaining
                let tipInterval = max(10, drill.durationSeconds / max(1, tips.count))
                let newIndex = min(elapsed / tipInterval, tips.count - 1)
                if newIndex != currentTipIndex {
                    withAnimation {
                        currentTipIndex = newIndex
                    }
                }

                if timeRemaining <= 0 {
                    completeSession()
                }
            }
        }
    }

    private func tapHit() {
        hitsLanded += 1
        if hitsLanded >= drill.targetHits {
            completeSession()
        }
    }

    private func completeSession() {
        guard !isCompleted else { return }
        isActive = false
        withAnimation(.spring(response: 0.5)) {
            isCompleted = true
        }

        if isDailyMission {
            appState.gameData.completeDailyMission(drill)
            coinsEarned = drill.coinReward * 2
        } else {
            appState.gameData.completeDrill(drill)
            coinsEarned = drill.coinReward
        }
    }
}

nonisolated struct DrillTip: Sendable {
    let icon: String
    let text: String

    static func tips(for category: DrillCategory) -> [DrillTip] {
        switch category {
        case .batting, .masterclass:
            return [
                DrillTip(icon: "figure.cricket", text: "Get into your stance. Feet shoulder-width apart, weight on the balls of your feet. Bat raised, eyes level."),
                DrillTip(icon: "eye.fill", text: "Watch the ball from the bowler's hand. Pick up the length early and decide your shot before the ball pitches."),
                DrillTip(icon: "arrow.forward", text: "Transfer your weight through the shot. Lead with your front shoulder and let the bat follow through the line."),
                DrillTip(icon: "bolt.fill", text: "Accelerate through contact. Don't decelerate before hitting \u{2014} maximum bat speed at the point of contact."),
                DrillTip(icon: "checkmark.circle.fill", text: "Follow through completely. A full follow-through ensures control and power. Hold your finish position.")
            ]
        case .bowling:
            return [
                DrillTip(icon: "figure.walk", text: "Mark your run-up. Consistent approach speed and rhythm are the foundation of accurate bowling."),
                DrillTip(icon: "hand.raised.fill", text: "Grip the ball with your index and middle fingers on the seam. Keep your wrist behind the ball at release."),
                DrillTip(icon: "target", text: "Pick your target on the pitch. Visualize exactly where you want the ball to land before you bowl."),
                DrillTip(icon: "arrow.down.forward", text: "Drive your front arm down and through. This generates pace and helps maintain a consistent release point."),
                DrillTip(icon: "bolt.fill", text: "Snap your wrist at release for maximum seam movement. Follow through towards the target.")
            ]
        case .fielding:
            return [
                DrillTip(icon: "figure.stand", text: "Stay low and balanced on the balls of your feet. Be ready to move in any direction at a moment's notice."),
                DrillTip(icon: "eye.fill", text: "Watch the ball off the bat. Track it all the way into your hands \u{2014} never take your eyes off it."),
                DrillTip(icon: "hands.sparkles.fill", text: "Soft hands! Give with the ball on impact. Cushion the catch rather than snatching at it."),
                DrillTip(icon: "arrow.left.and.right", text: "Move your feet first, then reach. Good footwork gets you in the best position for every ball."),
                DrillTip(icon: "checkmark.circle.fill", text: "Secure the ball against your body after catching. Complete the action before celebrating!")
            ]
        case .wicketkeeping:
            return [
                DrillTip(icon: "figure.stand", text: "Crouch low with weight forward. Fingers pointing down for balls below the stumps, up for balls above."),
                DrillTip(icon: "eye.fill", text: "Watch the ball from the bowler's hand, all the way through to your gloves. Anticipate the movement."),
                DrillTip(icon: "arrow.left.and.right", text: "Move laterally with quick, shuffling steps. Stay balanced and keep your head level."),
                DrillTip(icon: "hands.sparkles.fill", text: "Rise with the ball. Let your hands come up naturally with the bounce rather than reaching down."),
                DrillTip(icon: "bolt.fill", text: "Quick release! After a clean take, get the ball to the stumps fast for run-out opportunities.")
            ]
        }
    }
}
