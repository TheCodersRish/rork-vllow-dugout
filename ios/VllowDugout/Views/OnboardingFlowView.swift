import PhotosUI
import SwiftUI
import UIKit

struct OnboardingFlowView: View {
    let onComplete: () -> Void

    @State private var phase: Phase = .welcome
    @State private var welcomePage = 0
    @State private var profile = PlayerOnboardingProfile.draft()
    @State private var quizIndex = 0
    @State private var photoItem: PhotosPickerItem?
    @State private var showValidationHint = false
    @State private var validationMessage = ""

    private let welcomePages: [OnboardingPage] = [
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

    private enum Phase: Hashable {
        case welcome
        case quiz
        case identity
        case schedule
        case photoBio
        case teamLeague
        case youth
    }

    var body: some View {
        ZStack {
            AppTheme.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                progressHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                Group {
                    switch phase {
                    case .welcome:
                        welcomeSection
                    case .quiz:
                        quizSection
                    case .identity:
                        identitySection
                    case .schedule:
                        scheduleSection
                    case .photoBio:
                        photoBioSection
                    case .teamLeague:
                        teamLeagueSection
                    case .youth:
                        youthSection
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                bottomBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: photoItem) { _, new in
            Task { await loadPhoto(new) }
        }
        .alert("Almost there", isPresented: $showValidationHint) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(headerTitle)
                    .font(.system(size: 13, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer()
                Text(stepFraction)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.textTertiary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.cardSurfaceLight)
                        .frame(height: 4)
                    Capsule()
                        .fill(AppTheme.neonGreen)
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.spring(response: 0.45), value: progress)
                }
            }
            .frame(height: 4)
        }
    }

    private var headerTitle: String {
        switch phase {
        case .welcome: "WELCOME"
        case .quiz: "COACH CHAT"
        case .identity: "YOUR PROFILE"
        case .schedule: "TRAINING WEEK"
        case .photoBio: "DUGOUT ID"
        case .teamLeague: "SQUAD"
        case .youth: "YOUTH MODE"
        }
    }

    private var stepFraction: String {
        let (c, t) = stepCounts
        return "\(c)/\(t)"
    }

    private var stepCounts: (Int, Int) {
        let total = profile.isYouthMode ? 7 : 6
        let current: Int = switch phase {
        case .welcome: 1
        case .quiz: 2
        case .identity: 3
        case .schedule: 4
        case .photoBio: 5
        case .teamLeague: 6
        case .youth: 7
        }
        return (current, total)
    }

    private var progress: CGFloat {
        let (c, t) = stepCounts
        return CGFloat(c) / CGFloat(t)
    }

    private var welcomeSection: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            TabView(selection: $welcomePage) {
                ForEach(Array(welcomePages.enumerated()), id: \.offset) { index, page in
                    welcomePageContent(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            pageDots(count: welcomePages.count, current: welcomePage)
                .padding(.bottom, 24)

            Spacer(minLength: 0)
        }
    }

    private func welcomePageContent(_ page: OnboardingPage) -> some View {
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
                    .padding(.horizontal, 24)
            }
        }
        .padding(.horizontal, 24)
    }

    private func pageDots(count: Int, current: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? AppTheme.neonGreen : AppTheme.textTertiary)
                    .frame(width: index == current ? 28 : 8, height: 8)
            }
        }
    }

    private var quizSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if quizIndex == 0 {
                    coachBubble("Yo — I'm your Vllow coach. Three quick questions so I don't give you generic gym-bro advice. Deal?")
                    quizBlock(
                        title: "How would you rate your game right now?",
                        options: QuizSkillTier.allCases.map(\.rawValue)
                    ) { pick in
                        if let m = QuizSkillTier.allCases.first(where: { $0.rawValue == pick }) {
                            profile.quizSkill = m
                        }
                    } selection: profile.quizSkill.rawValue
                } else if quizIndex == 1 {
                    quizBlock(
                        title: "Where's your fitness this season?",
                        options: QuizFitnessLevel.allCases.map(\.rawValue)
                    ) { pick in
                        if let m = QuizFitnessLevel.allCases.first(where: { $0.rawValue == pick }) {
                            profile.quizFitness = m
                        }
                    } selection: profile.quizFitness.rawValue
                } else {
                    quizBlock(
                        title: "How do you usually eat?",
                        options: DietaryPreference.allCases.map(\.rawValue)
                    ) { pick in
                        if let m = DietaryPreference.allCases.first(where: { $0.rawValue == pick }) {
                            profile.dietaryPreference = m
                        }
                    } selection: profile.dietaryPreference.rawValue
                    userEchoBubble("Locked in — let's build your plan around that.")
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private func coachBubble(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineSpacing(4)
            }
            .padding(16)
            .background(AppTheme.cardSurface)
            .clipShape(
                .rect(
                    topLeadingRadius: 6,
                    bottomLeadingRadius: 18,
                    bottomTrailingRadius: 18,
                    topTrailingRadius: 18
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppTheme.border, lineWidth: 0.5)
            )
            Spacer(minLength: 40)
        }
    }

    private func userEchoBubble(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer(minLength: 40)
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(red: 0.07, green: 0.07, blue: 0.06))
                .padding(14)
                .background(AppTheme.neonGreen)
                .clipShape(
                    .rect(
                        topLeadingRadius: 18,
                        bottomLeadingRadius: 18,
                        bottomTrailingRadius: 6,
                        topTrailingRadius: 18
                    )
                )
        }
    }

    private func quizBlock(title: String, options: [String], onPick: @escaping (String) -> Void, selection: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            coachBubble(title)
            SinglePickChips(options: options, selected: selection, onSelect: onPick)
        }
    }

    private var identitySection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                labeledField("Display name") {
                    TextField("How we hype you on leaderboards", text: $profile.displayName)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                        .padding(14)
                        .background(AppTheme.cardSurfaceLight)
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 0.5))
                        .foregroundStyle(AppTheme.textPrimary)
                }

                labeledField("Age") {
                    HStack {
                        Stepper(value: $profile.age, in: 8...99) {
                            Text("\(profile.age)")
                                .font(.system(size: 20, weight: .black))
                                .foregroundStyle(AppTheme.textPrimary)
                                .frame(minWidth: 44, alignment: .leading)
                        }
                        .tint(AppTheme.neonGreen)
                        Spacer()
                    }
                    .padding(14)
                    .background(AppTheme.cardSurfaceLight)
                    .clipShape(.rect(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 0.5))
                }

                if profile.isYouthMode {
                    HStack(spacing: 10) {
                        Image(systemName: "figure.and.child.holdinghands")
                            .foregroundStyle(AppTheme.neonGreen)
                        Text("You'll get Youth Mode: age-fit drills, separated leaderboards, and safeguarding on by default.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(14)
                    .background(AppTheme.neonGreenDim)
                    .clipShape(.rect(cornerRadius: 12))
                }

                labeledField("Position") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                        ForEach(PlayingPosition.allCases, id: \.self) { pos in
                            let on = profile.position == pos
                            Button {
                                profile.position = pos
                            } label: {
                                Text(pos.rawValue)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(on ? Color(red: 0.07, green: 0.07, blue: 0.06) : AppTheme.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(on ? AppTheme.neonGreen : AppTheme.cardSurface)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(on ? .clear : AppTheme.border, lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                labeledField("Experience") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 8)], spacing: 8) {
                        ForEach(ExperienceLevel.allCases, id: \.self) { level in
                            let on = profile.experienceLevel == level
                            Button {
                                profile.experienceLevel = level
                            } label: {
                                Text(level.rawValue)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(on ? Color(red: 0.07, green: 0.07, blue: 0.06) : AppTheme.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(on ? AppTheme.neonGreen : AppTheme.cardSurface)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(on ? .clear : AppTheme.border, lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                labeledField("Goals (pick a few)") {
                    GoalMultiChips(options: OnboardingGoals.options, selected: $profile.goals, maxSelection: 5)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private var scheduleSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tap days you train, then when you're usually free. Drag-free for now — tap is faster between nets.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)

                ForEach(1...7, id: \.self) { weekday in
                    dayScheduleRow(weekday: weekday)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private func weekdayLabel(_ w: Int) -> String {
        let labels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return labels[(w - 1) % 7]
    }

    private func dayScheduleRow(weekday: Int) -> some View {
        let binding = Binding<DayConfig>(
            get: {
                profile.weeklySchedule.byWeekday[weekday] ?? .restDay()
            },
            set: { new in
                profile.weeklySchedule.byWeekday[weekday] = new
            }
        )

        return VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: Binding(
                get: { binding.wrappedValue.isTrainingDay },
                set: { on in
                    var d = binding.wrappedValue
                    d.isTrainingDay = on
                    if on && !d.morning && !d.afternoon && !d.evening {
                        d = DayConfig.defaultTraining()
                    }
                    if !on { d = .restDay() }
                    binding.wrappedValue = d
                }
            )) {
                Text(weekdayLabel(weekday))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .tint(AppTheme.neonGreen)

            if binding.wrappedValue.isTrainingDay {
                HStack(spacing: 8) {
                    timeChip("AM", on: binding.wrappedValue.morning) {
                        var d = binding.wrappedValue
                        d.morning.toggle()
                        binding.wrappedValue = d
                    }
                    timeChip("PM", on: binding.wrappedValue.afternoon) {
                        var d = binding.wrappedValue
                        d.afternoon.toggle()
                        binding.wrappedValue = d
                    }
                    timeChip("Eve", on: binding.wrappedValue.evening) {
                        var d = binding.wrappedValue
                        d.evening.toggle()
                        binding.wrappedValue = d
                    }
                }
            }
        }
        .padding(16)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 0.5))
    }

    private func timeChip(_ label: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(on ? Color(red: 0.07, green: 0.07, blue: 0.06) : AppTheme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(on ? AppTheme.neonGreen : AppTheme.cardSurfaceLight)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppTheme.border, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    private var photoBioSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 12) {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.cardSurfaceLight)
                                .frame(width: 112, height: 112)
                            if let data = profile.profilePhotoJPEGData,
                               let ui = UIImage(data: data) {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 112, height: 112)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                            Circle()
                                .stroke(AppTheme.neonGreen.opacity(0.5), lineWidth: 2)
                                .frame(width: 112, height: 112)
                        }
                    }
                    Text("Profile photo — shows on leaderboards & challenges")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)

                labeledField("Bio") {
                    TextField("One-liner vibe — what you're working toward", text: $profile.bio, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(14)
                        .background(AppTheme.cardSurfaceLight)
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 0.5))
                        .foregroundStyle(AppTheme.textPrimary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private var teamLeagueSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                labeledField("Club / team") {
                    TextField("e.g. Houston Cricket Club", text: $profile.teamName)
                        .textInputAutocapitalization(.words)
                        .padding(14)
                        .background(AppTheme.cardSurfaceLight)
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 0.5))
                        .foregroundStyle(AppTheme.textPrimary)
                }

                labeledField("League") {
                    TextField("e.g. MLC Junior Regional", text: $profile.leagueName)
                        .padding(14)
                        .background(AppTheme.cardSurfaceLight)
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 0.5))
                        .foregroundStyle(AppTheme.textPrimary)
                }

                Text("We'll use this later for teammate challenges & club walls — nothing public until you say so.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private var youthSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.neonGreen)
                    Text("Youth Mode & safeguarding")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                }

                Text("Vllow keeps training hype high and interactions safe. Parents stay in the loop on Expert Coach reviews.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)

                labeledField("Parent / guardian email") {
                    TextField("name@email.com", text: $profile.parentEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding(14)
                        .background(AppTheme.cardSurfaceLight)
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 0.5))
                        .foregroundStyle(AppTheme.textPrimary)
                }

                Toggle(isOn: $profile.safeguardingAccepted) {
                    Text("I understand chats & reviews are moderated for safety. Bullying isn't cricket — report anything off.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .tint(AppTheme.neonGreen)
                .padding(14)
                .background(AppTheme.cardSurface)
                .clipShape(.rect(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))

                Toggle(isOn: $profile.youthParentAwarenessConfirmed) {
                    Text("A parent/guardian knows I'm using Vllow and can approve Expert Coach video reviews.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .tint(AppTheme.neonGreen)
                .padding(14)
                .background(AppTheme.cardSurface)
                .clipShape(.rect(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private func labeledField<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .heavy))
                .tracking(1.5)
                .foregroundStyle(AppTheme.textSecondary)
            content()
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            if phase == .welcome, welcomePage < welcomePages.count - 1 {
                Button {
                    withAnimation { onComplete() }
                } label: {
                    Text("Skip intro")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }

            Button {
                advance()
            } label: {
                HStack(spacing: 10) {
                    Text(primaryButtonTitle)
                        .font(.system(size: 17, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(Color(red: 0.07, green: 0.07, blue: 0.06))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppTheme.neonGreen)
                .clipShape(.rect(cornerRadius: 28))
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: phase)
        }
    }

    private var primaryButtonTitle: String {
        switch phase {
        case .welcome:
            welcomePage < welcomePages.count - 1 ? "Next" : "Start setup"
        case .quiz:
            quizIndex < 2 ? "Next question" : "Continue"
        case .teamLeague:
            profile.isYouthMode ? "Continue" : "Enter the Dugout"
        case .youth:
            "Enter the Dugout"
        default:
            "Continue"
        }
    }

    private func advance() {
        switch phase {
        case .welcome:
            if welcomePage < welcomePages.count - 1 {
                withAnimation(.spring(response: 0.4)) { welcomePage += 1 }
            } else {
                withAnimation { phase = .quiz }
            }

        case .quiz:
            if quizIndex < 2 {
                withAnimation { quizIndex += 1 }
            } else {
                withAnimation { phase = .identity }
            }

        case .identity:
            guard validateIdentity() else { return }
            withAnimation { phase = .schedule }

        case .schedule:
            guard validateSchedule() else { return }
            withAnimation { phase = .photoBio }

        case .photoBio:
            withAnimation { phase = .teamLeague }

        case .teamLeague:
            if profile.isYouthMode {
                withAnimation { phase = .youth }
            } else {
                finish()
            }

        case .youth:
            guard validateYouth() else { return }
            finish()
        }
    }

    private func validateIdentity() -> Bool {
        let name = profile.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            validationMessage = "Add a display name so we can hype you properly."
            showValidationHint = true
            return false
        }
        if profile.goals.isEmpty {
            validationMessage = "Pick at least one goal — it steers your feed."
            showValidationHint = true
            return false
        }
        return true
    }

    private func validateSchedule() -> Bool {
        for d in 1...7 {
            guard let cfg = profile.weeklySchedule.byWeekday[d], cfg.isTrainingDay else { continue }
            if cfg.morning || cfg.afternoon || cfg.evening { return true }
        }
        validationMessage = "Choose at least one training day with a time window (AM, PM, or Eve)."
        showValidationHint = true
        return false
    }

    private func validateYouth() -> Bool {
        let email = profile.parentEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard email.contains("@"), email.contains(".") else {
            validationMessage = "Add a real parent/guardian email so we can keep Expert Reviews safe."
            showValidationHint = true
            return false
        }
        guard profile.safeguardingAccepted, profile.youthParentAwarenessConfirmed else {
            validationMessage = "Please confirm safeguarding and parent awareness to continue."
            showValidationHint = true
            return false
        }
        return true
    }

    private func finish() {
        OnboardingProfileStore.save(profile)
        onComplete()
    }

    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            let compressed = compressJPEG(data, maxBytes: 480_000)
            profile.profilePhotoJPEGData = compressed
        }
    }

    private func compressJPEG(_ data: Data, maxBytes: Int) -> Data {
        guard let image = UIImage(data: data) else { return data }
        var quality: CGFloat = 0.85
        var result = data
        while result.count > maxBytes, quality > 0.35 {
            if let d = image.jpegData(compressionQuality: quality) {
                result = d
            }
            quality -= 0.1
        }
        return result
    }
}

// MARK: - Chips

private struct SinglePickChips: View {
    let options: [String]
    let selected: String
    let onSelect: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 8)], spacing: 8) {
            ForEach(options, id: \.self) { opt in
                let on = selected == opt
                Button {
                    onSelect(opt)
                } label: {
                    Text(opt)
                        .font(.system(size: 13, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(on ? Color(red: 0.07, green: 0.07, blue: 0.06) : AppTheme.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(on ? AppTheme.neonGreen : AppTheme.cardSurface)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(on ? .clear : AppTheme.border, lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct GoalMultiChips: View {
    let options: [String]
    @Binding var selected: [String]
    let maxSelection: Int

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 8)], spacing: 8) {
            ForEach(options, id: \.self) { opt in
                let on = selected.contains(opt)
                Button {
                    toggle(opt)
                } label: {
                    Text(opt)
                        .font(.system(size: 13, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(on ? Color(red: 0.07, green: 0.07, blue: 0.06) : AppTheme.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(on ? AppTheme.neonGreen : AppTheme.cardSurface)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(on ? .clear : AppTheme.border, lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func toggle(_ opt: String) {
        if let idx = selected.firstIndex(of: opt) {
            selected.remove(at: idx)
        } else if selected.count < maxSelection {
            selected.append(opt)
        }
    }
}
