import SwiftUI

struct CoachView: View {
    let appState: AppState
    @State private var viewModel = CoachViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var showDrillSession = false
    @State private var selectedDrill: Drill?

    var body: some View {
        VStack(spacing: 0) {
            coachHeader
            chatMessages
            inputBar
        }
        .background(AppTheme.darkBg)
        .onAppear {
            viewModel.configure(with: appState)
        }
        .fullScreenCover(isPresented: $showDrillSession) {
            if let drill = selectedDrill {
                DrillSessionView(drill: drill, appState: appState)
            }
        }
    }

    private var coachHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Circle()
                    .fill(AppTheme.neonGreen)
                    .frame(width: 5, height: 5)
                    .shadow(color: AppTheme.neonGreen.opacity(0.6), radius: 3)

                Text("LIVE AI ANALYSIS")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(AppTheme.textSecondary)

                Spacer()

                if appState.gameData.coachSessionCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 9))
                        Text("\(appState.gameData.coachSessionCount) sessions")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(AppTheme.textTertiary)
                }
            }

            HStack(spacing: 0) {
                Text("Focus: ")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(viewModel.focusTopic)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var chatMessages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(viewModel.messages) { message in
                        messageView(for: message)
                            .id(message.id)
                    }

                    if viewModel.isLoading {
                        typingIndicator
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) {
                withAnimation {
                    if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.isLoading) { _, newValue in
                if newValue {
                    withAnimation {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func messageView(for message: ChatMessage) -> some View {
        switch message.role {
        case .assistant:
            assistantBubble(message)
        case .user:
            userBubble(message)
        }
    }

    private func assistantBubble(_ message: ChatMessage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 10))
                    .foregroundStyle(AppTheme.neonGreen)
                Text("FR-03 ASSISTANT")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Text(message.content)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.textPrimary)
                .lineSpacing(4)
                .padding(18)
                .background(AppTheme.cardSurface)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 4,
                        bottomLeadingRadius: 20,
                        bottomTrailingRadius: 20,
                        topTrailingRadius: 20
                    )
                )
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 4,
                        bottomLeadingRadius: 20,
                        bottomTrailingRadius: 20,
                        topTrailingRadius: 20
                    )
                    .stroke(AppTheme.border, lineWidth: 0.5)
                )

            if let drill = message.drillAttachment {
                drillAttachmentView(drill)
            }

            if !message.suggestedQuestions.isEmpty {
                suggestedQuestionsView(message.suggestedQuestions)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func drillAttachmentView(_ attachment: DrillAttachment) -> some View {
        Button {
            launchDrill(from: attachment)
        } label: {
            Color(AppTheme.cardSurface)
                .aspectRatio(16/9, contentMode: .fit)
                .overlay {
                    AsyncImage(url: URL(string: attachment.imageURL)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                                .saturation(0.3)
                        }
                    }
                    .allowsHitTesting(false)
                }
                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.3),
                            .init(color: .black.opacity(0.7), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .clipShape(.rect(cornerRadius: 20))
                .overlay(alignment: .center) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 52, height: 52)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                        Image(systemName: "play.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.black)
                            .frame(width: 36, height: 36)
                            .background(.white)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(attachment.title)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text(attachment.subtitle)
                                .font(.system(size: 9, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding(16)
                }
                .overlay(alignment: .topTrailing) {
                    Text("TAP TO START")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.neonGreen.opacity(0.3))
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(12)
                }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: showDrillSession)
    }

    private func suggestedQuestionsView(_ questions: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(questions, id: \.self) { question in
                    Button {
                        viewModel.inputText = question
                        viewModel.sendMessage()
                    } label: {
                        Text(question)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.neonGreen)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppTheme.neonGreen.opacity(0.1))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(AppTheme.neonGreen.opacity(0.3), lineWidth: 0.5)
                            )
                    }
                }
            }
        }
        .contentMargins(.horizontal, 0)
    }

    private func launchDrill(from attachment: DrillAttachment) {
        if let drillID = attachment.linkedDrillID,
           let drill = MockData.drills.first(where: { $0.id == drillID }) {
            selectedDrill = drill
            showDrillSession = true
        } else if let drill = MockData.drills.first(where: {
            $0.title.lowercased().contains(attachment.title.lowercased().prefix(10).description) ||
            attachment.title.lowercased().contains($0.title.lowercased().prefix(10).description)
        }) {
            selectedDrill = drill
            showDrillSession = true
        } else {
            selectedDrill = MockData.drills.first
            showDrillSession = true
        }
    }

    private func userBubble(_ message: ChatMessage) -> some View {
        VStack(alignment: .trailing, spacing: 6) {
            Text(message.content)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(AppTheme.neonGreen.opacity(0.12))
                .background(Color(red: 0.15, green: 0.2, blue: 0.13))
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: 20,
                        bottomTrailingRadius: 20,
                        topTrailingRadius: 4
                    )
                )

            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 8))
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var typingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(AppTheme.neonGreen.opacity(0.6))
                    .frame(width: 6, height: 6)
                    .offset(y: viewModel.isLoading ? -3 : 0)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(i) * 0.15),
                        value: viewModel.isLoading
                    )
            }
        }
        .padding(14)
        .background(AppTheme.cardSurface)
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            Button {
                viewModel.showQuickActions.toggle()
            } label: {
                Image(systemName: viewModel.showQuickActions ? "xmark.circle.fill" : "plus.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(viewModel.showQuickActions ? AppTheme.neonGreen : AppTheme.textSecondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .frame(width: 44, height: 44)

            TextField("Ask about your technique...", text: $viewModel.inputText)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textPrimary)
                .focused($isInputFocused)
                .onSubmit { viewModel.sendMessage() }
                .tint(AppTheme.neonGreen)

            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: viewModel.inputText.isEmpty ? "mic.fill" : "arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(viewModel.inputText.isEmpty ? AppTheme.textPrimary : .black)
                    .frame(width: 40, height: 40)
                    .background(viewModel.inputText.isEmpty ? AppTheme.cardSurfaceLight : AppTheme.neonGreen)
                    .clipShape(Circle())
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .background(AppTheme.cardSurface.opacity(0.9))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .overlay(alignment: .top) {
            if viewModel.showQuickActions {
                quickActionsMenu
                    .offset(y: -130)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.35), value: viewModel.showQuickActions)
    }

    private var quickActionsMenu: some View {
        HStack(spacing: 10) {
            quickActionButton(icon: "figure.cricket", label: "Batting") {
                viewModel.inputText = "Show me a batting drill"
                viewModel.sendMessage()
                viewModel.showQuickActions = false
            }
            quickActionButton(icon: "figure.bowling", label: "Bowling") {
                viewModel.inputText = "Show me a bowling drill"
                viewModel.sendMessage()
                viewModel.showQuickActions = false
            }
            quickActionButton(icon: "hand.raised.fill", label: "Fielding") {
                viewModel.inputText = "Show me a fielding drill"
                viewModel.sendMessage()
                viewModel.showQuickActions = false
            }
            quickActionButton(icon: "chart.line.uptrend.xyaxis", label: "Stats") {
                viewModel.inputText = "Analyze my performance stats"
                viewModel.sendMessage()
                viewModel.showQuickActions = false
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .background(AppTheme.cardSurface.opacity(0.95))
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
    }

    private func quickActionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.neonGreen)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.neonGreen.opacity(0.1))
                    .clipShape(Circle())
                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
