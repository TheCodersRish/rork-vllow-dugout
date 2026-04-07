import SwiftUI

struct MealPlanView: View {
    let appState: AppState
    @State private var viewModel = MealPlanViewModel()
    @State private var showGoalPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                goalSelector
                generateButton

                if viewModel.isGenerating {
                    loadingView
                } else if let plan = viewModel.currentPlan {
                    macroSummary(plan)
                    mealsSection(plan)
                } else {
                    emptyState
                }

                if viewModel.savedPlans.count > 1 {
                    savedPlansSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.darkBg)
    }

    private var goalSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "target")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.neonGreen)
                Text("MEAL GOAL")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MealGoal.allCases, id: \.self) { goal in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.selectedGoal = goal
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: goal.icon)
                                    .font(.system(size: 13))
                                Text(goal.rawValue)
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundStyle(viewModel.selectedGoal == goal ? Color(red: 0.07, green: 0.07, blue: 0.06) : AppTheme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(viewModel.selectedGoal == goal ? AppTheme.neonGreen : AppTheme.cardSurface)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(viewModel.selectedGoal == goal ? .clear : AppTheme.border, lineWidth: 0.5)
                            )
                        }
                        .sensoryFeedback(.selection, trigger: viewModel.selectedGoal)
                    }
                }
            }
            .contentMargins(.horizontal, 0)

            Text(viewModel.selectedGoal.description)
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.textTertiary)
        }
    }

    private var generateButton: some View {
        Button {
            Task { await viewModel.generateMealPlan() }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Generate Meal Plan")
                        .font(.system(size: 16, weight: .bold))
                    Text("AI-powered nutrition for cricket athletes")
                        .font(.system(size: 11))
                        .opacity(0.7)
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 22))
            }
            .foregroundStyle(Color(red: 0.07, green: 0.07, blue: 0.06))
            .padding(18)
            .background(
                LinearGradient(
                    colors: [AppTheme.neonGreen, AppTheme.neonGreen.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 18))
        }
        .disabled(viewModel.isGenerating)
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.currentPlan?.id)
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(AppTheme.border, lineWidth: 3)
                    .frame(width: 60, height: 60)
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(AppTheme.neonGreen, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                Image(systemName: "sparkles")
                    .font(.system(size: 22))
                    .foregroundStyle(AppTheme.neonGreen)
            }

            VStack(spacing: 6) {
                Text("Generating Your Meal Plan")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Our AI is crafting the perfect nutrition plan for your \(viewModel.selectedGoal.rawValue.lowercased())...")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func macroSummary(_ plan: MealPlan) -> some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: plan.goal.icon)
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.neonGreen)
                        Text(plan.goal.rawValue.uppercased())
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(1.5)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Text("\(plan.totalCalories)")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                    + Text(" kcal")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
                Text(plan.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppTheme.textTertiary)
            }

            HStack(spacing: 12) {
                macroChip(label: "PROTEIN", value: "\(plan.totalProtein)g", color: .red)
                macroChip(label: "CARBS", value: "\(plan.totalCarbs)g", color: .orange)
                macroChip(label: "FAT", value: "\(plan.totalFat)g", color: .yellow)
            }
        }
        .padding(18)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private func macroChip(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.15), lineWidth: 0.5)
        )
    }

    private func mealsSection(_ plan: MealPlan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.neonGreen)
                Text("TODAY'S MEALS")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ForEach(plan.meals) { meal in
                mealCard(meal)
            }
        }
    }

    private func mealCard(_ meal: Meal) -> some View {
        let isExpanded = viewModel.expandedMealID == meal.id

        return VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    viewModel.expandedMealID = isExpanded ? nil : meal.id
                }
            } label: {
                HStack(spacing: 14) {
                    mealTypeIcon(meal.type)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(meal.type.rawValue.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1.5)
                            .foregroundStyle(AppTheme.textTertiary)
                        Text(meal.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(1)
                        Text(meal.description)
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text("\(meal.calories)")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("kcal")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(AppTheme.textTertiary)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.textTertiary)
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    Divider()
                        .background(AppTheme.border)

                    HStack(spacing: 8) {
                        miniMacro(label: "Protein", value: "\(meal.protein)g", color: .red)
                        miniMacro(label: "Carbs", value: "\(meal.carbs)g", color: .orange)
                        miniMacro(label: "Fat", value: "\(meal.fat)g", color: .yellow)
                        miniMacro(label: "Prep", value: meal.prepTime, color: .cyan)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("INGREDIENTS")
                            .font(.system(size: 9, weight: .heavy))
                            .tracking(1.5)
                            .foregroundStyle(AppTheme.textSecondary)

                        FlowLayout(spacing: 6) {
                            ForEach(meal.ingredients, id: \.self) { ingredient in
                                Text(ingredient)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(AppTheme.cardSurfaceLight)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private func mealTypeIcon(_ type: MealType) -> some View {
        let color: Color = switch type {
        case .breakfast: .orange
        case .morningSnack: .yellow
        case .lunch: .green
        case .afternoonSnack: .cyan
        case .dinner: .purple
        }

        return Image(systemName: type.icon)
            .font(.system(size: 16))
            .foregroundStyle(color)
            .frame(width: 40, height: 40)
            .background(color.opacity(0.12))
            .clipShape(Circle())
    }

    private func miniMacro(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.06))
        .clipShape(.rect(cornerRadius: 8))
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.textTertiary)

            VStack(spacing: 6) {
                Text("No Meal Plan Yet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Select your goal and tap Generate to get a personalized AI meal plan for cricket performance.")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 50)
    }

    private var savedPlansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.neonGreen)
                Text("RECENT PLANS")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ForEach(viewModel.savedPlans.dropFirst().prefix(3)) { plan in
                Button {
                    withAnimation(.spring(response: 0.35)) {
                        viewModel.currentPlan = plan
                        viewModel.selectedGoal = plan.goal
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: plan.goal.icon)
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.neonGreen)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.neonGreen.opacity(0.1))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(plan.goal.rawValue)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("\(plan.totalCalories) kcal • \(plan.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.system(size: 11))
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .padding(14)
                    .background(AppTheme.cardSurface)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppTheme.border, lineWidth: 0.5)
                    )
                }
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
