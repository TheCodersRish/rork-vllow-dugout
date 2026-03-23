import SwiftUI

struct MatchRecorderView: View {
    let appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var runs: String = ""
    @State private var balls: String = ""
    @State private var selectedOpponent: String = ""
    @State private var isRecorded: Bool = false
    @State private var coinsEarned: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            header
            if isRecorded {
                recordedView
            } else {
                formContent
            }
        }
        .background(AppTheme.darkBg)
        .preferredColorScheme(.dark)
        .onAppear {
            if selectedOpponent.isEmpty {
                selectedOpponent = MockData.opponents.randomElement() ?? "Melbourne Renegades"
            }
        }
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
            Text(isRecorded ? "MATCH RECORDED" : "RECORD MATCH")
                .font(.system(size: 12, weight: .bold))
                .tracking(3)
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(20)
    }

    private var formContent: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "cricket.ball.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.neonGreen)
                .padding(.bottom, 8)

            Text("Log Your Performance")
                .font(.system(size: 26, weight: .black))
                .foregroundStyle(AppTheme.textPrimary)

            VStack(spacing: 14) {
                fieldRow(label: "RUNS SCORED", placeholder: "67", text: $runs)
                fieldRow(label: "BALLS FACED", placeholder: "45", text: $balls)
            }
            .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 8) {
                Text("OPPONENT")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)

                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(MockData.opponents, id: \.self) { opp in
                            Button {
                                selectedOpponent = opp
                            } label: {
                                Text(opp)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(selectedOpponent == opp ? .black : AppTheme.textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedOpponent == opp ? AppTheme.neonGreen : AppTheme.cardSurface)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(selectedOpponent == opp ? .clear : AppTheme.border, lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                recordMatch()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text("RECORD MATCH")
                        .font(.system(size: 15, weight: .bold))
                        .tracking(1)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(canRecord ? AppTheme.neonGreen : AppTheme.cardSurfaceLight)
                .clipShape(.rect(cornerRadius: 20))
            }
            .disabled(!canRecord)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .sensoryFeedback(.impact(weight: .heavy), trigger: isRecorded)
        }
    }

    private var recordedView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.neonGreen.opacity(0.15))
                    .frame(width: 140, height: 140)
                Circle()
                    .fill(AppTheme.cardSurface)
                    .frame(width: 110, height: 110)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppTheme.neonGreen)
            }

            Text("Match Recorded!")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(AppTheme.textPrimary)

            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundStyle(AppTheme.goldAccent)
                Text("+\(coinsEarned) V-COINS")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(AppTheme.goldAccent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.goldAccent.opacity(0.12))
            .clipShape(Capsule())

            let runsInt = Int(runs) ?? 0
            let ballsInt = Int(balls) ?? 1
            let sr = ballsInt > 0 ? (Double(runsInt) / Double(ballsInt)) * 100 : 0

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("RUNS")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(runs)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("BALLS")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(balls)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("SR")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(String(format: "%.1f", sr))
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AppTheme.neonGreen)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(20)
            .background(AppTheme.cardSurface)
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal, 24)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("DONE")
                    .font(.system(size: 15, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppTheme.neonGreen)
                    .clipShape(.rect(cornerRadius: 20))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private func fieldRow(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(2)
                .foregroundStyle(AppTheme.textSecondary)

            TextField(placeholder, text: text)
                .keyboardType(.numberPad)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(16)
                .background(AppTheme.cardSurface)
                .clipShape(.rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.border, lineWidth: 0.5)
                )
                .tint(AppTheme.neonGreen)
        }
    }

    private var canRecord: Bool {
        guard let r = Int(runs), let b = Int(balls) else { return false }
        return r >= 0 && b > 0 && !selectedOpponent.isEmpty
    }

    private func recordMatch() {
        guard let r = Int(runs), let b = Int(balls) else { return }
        appState.gameData.recordMatch(runs: r, balls: b, opponent: selectedOpponent)

        let sr = b > 0 ? (Double(r) / Double(b)) * 100 : 0
        var bonus = r * 3
        if sr > 150 { bonus += 100 } else if sr > 120 { bonus += 50 }
        if r >= 50 { bonus += 150 }
        if r >= 100 { bonus += 300 }
        coinsEarned = bonus

        withAnimation(.spring(response: 0.5)) {
            isRecorded = true
        }
    }
}
