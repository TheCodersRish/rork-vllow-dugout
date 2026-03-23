import SwiftUI

struct MealPlansView: View {
    let appState: AppState
    @State private var selectedCategory: MealPlanCategory = .all

    private let items = MockData.mealPlanItems

    private var filteredItems: [MealPlanItem] {
        if selectedCategory == .all { return items }
        return items.filter { $0.category == selectedCategory }
    }

    private var weeklyCalorieTarget: Int { 2400 }
    private var avgDailyProtein: Int { 145 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    weekFocusCard
                    hydrationCard
                    categoryFilter
                    mealListSection
                    groceryTeaser
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background(AppTheme.darkBg)
            .navigationDestination(for: MealPlanItem.self) { item in
                MealPlanDetailView(item: item)
            }
        }
    }

    private var weekFocusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textSecondary)
                Text("THIS WEEK'S FUEL")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Train hard.")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Eat like it.")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.neonGreen)
                        .clipShape(.rect(cornerRadius: 6))
                }
                Spacer()
            }

            HStack(spacing: 12) {
                macroPill(title: "TARGET", value: "\(weeklyCalorieTarget)", unit: "kcal / day")
                macroPill(title: "PROTEIN", value: "\(avgDailyProtein)", unit: "g avg")
            }

            Text("Plans adapt to training load and match week — same energy as your drills.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if appState.winStreak > 0 {
                Text("\(appState.winStreak)-day training streak — stack protein on heavy days.")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.neonGreen.opacity(0.9))
            }
        }
        .padding(24)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private func macroPill(title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .tracking(2)
                .foregroundStyle(AppTheme.textTertiary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(unit)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cardSurfaceLight)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private var hydrationCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.neonGreenDim)
                    .frame(width: 52, height: 52)
                Image(systemName: "drop.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(AppTheme.neonGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("HYDRATION TARGET")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
                Text("3.0 – 3.5 L on training days")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Sip through nets — dehydration shows up as bad timing before bad technique.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.neonGreen.opacity(0.25), lineWidth: 0.5)
        )
    }

    private var categoryFilter: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(AppTheme.neonGreen)
                    .frame(width: 6, height: 6)
                Text("FILTER PLANS")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(MealPlanCategory.allCases, id: \.self) { category in
                        Button {
                            withAnimation(.snappy) { selectedCategory = category }
                        } label: {
                            Text(category.rawValue)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(selectedCategory == category ? .black : AppTheme.textPrimary)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(selectedCategory == category ? AppTheme.neonGreen : AppTheme.cardSurface)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(selectedCategory == category ? .clear : AppTheme.border, lineWidth: 0.5)
                                )
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var mealListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("MEALS & SNACKS")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer()
                Text("\(filteredItems.count) items")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppTheme.textTertiary)
            }

            LazyVStack(spacing: 14) {
                ForEach(filteredItems) { item in
                    NavigationLink(value: item) {
                        mealRowCard(item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func mealRowCard(_ item: MealPlanItem) -> some View {
        HStack(spacing: 14) {
            Color(AppTheme.cardSurfaceLight)
                .frame(width: 96, height: 96)
                .overlay {
                    AsyncImage(url: URL(string: item.imageURL)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 28))
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                    .allowsHitTesting(false)
                }
                .clipShape(.rect(cornerRadius: 14))
                .overlay(alignment: .topLeading) {
                    Text(item.slot.rawValue.uppercased())
                        .font(.system(size: 7, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .background(AppTheme.cardSurface.opacity(0.85))
                        .clipShape(Capsule())
                        .padding(8)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)

                Text(item.highlight)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 10) {
                    Label("\(item.calories) kcal", systemImage: "flame.fill")
                    Text("•")
                    Text("\(item.proteinG)g protein")
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppTheme.textTertiary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.textTertiary)
        }
        .padding(14)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private var groceryTeaser: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "basket.fill")
                    .foregroundStyle(AppTheme.goldAccent)
                Text("GROCERY LIST")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Text("Screenshot your picks or share a list before the weekend shop — full one-tap export ships with your next update.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppTheme.cardSurface, AppTheme.cardSurfaceLight.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }
}

struct MealPlanDetailView: View {
    let item: MealPlanItem

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                content
            }
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.darkBg)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.darkBg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var hero: some View {
        Color(AppTheme.cardSurface)
            .aspectRatio(4 / 3, contentMode: .fit)
            .overlay {
                AsyncImage(url: URL(string: item.imageURL)) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                            .saturation(0.85)
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
                .allowsHitTesting(false)
            }
            .clipped()
            .overlay(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [.clear, AppTheme.darkBg.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
            }
            .overlay(alignment: .topTrailing) {
                Text(item.slot.rawValue.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .background(AppTheme.cardSurface.opacity(0.6))
                    .clipShape(Capsule())
                    .padding(16)
            }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("RECIPE CARD")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(AppTheme.textSecondary)
                    Rectangle()
                        .fill(AppTheme.border)
                        .frame(width: 32, height: 1)
                }

                Text(item.title)
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
                    .tracking(-0.5)

                Text(item.highlight)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            HStack(spacing: 10) {
                macroBlock("kcal", "\(item.calories)")
                macroBlock("PRO", "\(item.proteinG)g")
                macroBlock("CARB", "\(item.carbsG)g")
                macroBlock("FAT", "\(item.fatG)g")
            }

            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .foregroundStyle(AppTheme.neonGreen)
                Text("Prep \(item.prepMinutes) min")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.cardSurface)
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.border, lineWidth: 0.5)
            )

            VStack(alignment: .leading, spacing: 14) {
                Text("INGREDIENTS")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(AppTheme.textSecondary)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(item.ingredients, id: \.self) { line in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(AppTheme.neonGreen)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            Text(line)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("COACH NOTES")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(AppTheme.textSecondary)

                Text(item.chefNotes)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(4)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.neonGreenDim)
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.neonGreen.opacity(0.35), lineWidth: 0.5)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }

    private func macroBlock(_ title: String, _ value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(AppTheme.textPrimary)
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundStyle(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }
}

#Preview("Meal Plans") {
    MealPlansView(appState: AppState())
}
