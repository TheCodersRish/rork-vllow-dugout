import SwiftUI

struct StoreView: View {
    let appState: AppState
    @State private var selectedCategory: ProductCategory = .all
    @State private var showRedeemAlert = false
    @State private var redeemResult: String = ""
    private let products = MockData.products

    private var filteredProducts: [Product] {
        if selectedCategory == .all { return products }
        return products.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    goalTracker
                    categoryFilter
                    productGrid
                    promotionalSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background(AppTheme.darkBg)
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product, appState: appState)
            }
        }
    }

    private var goalTracker: some View {
        let targetProduct = products.first(where: { $0.category == .bats }) ?? products[0]
        let targetCoins = targetProduct.priceCoins
        let currentCoins = appState.vCoins
        let progress = min(Double(currentCoins) / Double(targetCoins), 1.0)
        let remaining = max(targetCoins - currentCoins, 0)

        return VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("GOAL TRACKER")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                HStack(spacing: 0) {
                    Text("\(Int(progress * 100))% to your ")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(targetProduct.name)
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.neonGreen)
                        .clipShape(.rect(cornerRadius: 6))
                }
            }

            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppTheme.cardSurfaceLight)
                            .frame(height: 6)

                        Capsule()
                            .fill(AppTheme.textPrimary)
                            .frame(width: geo.size.width * progress, height: 6)
                            .animation(.spring(response: 0.5), value: progress)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(currentCoins.formatted()) / \(targetCoins.formatted()) V-Coins")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                    if remaining > 0 {
                        Text("\(remaining.formatted()) remaining")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(AppTheme.textPrimary)
                    } else {
                        Text("READY TO REDEEM!")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(AppTheme.neonGreen)
                    }
                }
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

    private var categoryFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(ProductCategory.allCases, id: \.self) { category in
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
        .contentMargins(.horizontal, 0)
        .scrollIndicators(.hidden)
    }

    private var productGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(filteredProducts) { product in
                NavigationLink(value: product) {
                    productCard(product)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func productCard(_ product: Product) -> some View {
        let redeemed = appState.gameData.isRedeemed(product.id)
        return VStack(spacing: 14) {
            Color(AppTheme.cardSurfaceLight)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    AsyncImage(url: URL(string: product.imageURL)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                                .saturation(0.8)
                        } else {
                            Image(systemName: "sportscourt.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                    .allowsHitTesting(false)
                }
                .clipShape(.rect(cornerRadius: 14))
                .overlay(alignment: .topTrailing) {
                    if redeemed {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.neonGreen)
                            .padding(8)
                    }
                }

            VStack(spacing: 4) {
                Text(product.name)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(product.subtitle.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            if redeemed {
                Text("OWNED")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.neonGreen)
            } else {
                HStack(spacing: 2) {
                    Text("\(product.priceCoins.formatted())")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(appState.vCoins >= product.priceCoins ? AppTheme.textPrimary : AppTheme.textTertiary)
                    Text("V")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .padding(14)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(redeemed ? AppTheme.neonGreen.opacity(0.3) : AppTheme.border, lineWidth: redeemed ? 1 : 0.5)
        )
    }

    private var promotionalSection: some View {
        VStack(spacing: 12) {
            Button {
                selectedCategory = .all
            } label: {
                VStack(alignment: .leading, spacing: 14) {
                    Text("LIMITED DROP")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppTheme.neonGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.neonGreen.opacity(0.1))
                        .clipShape(Capsule())

                    Text("Signed Dugout\nSeries")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(2)

                    Text("Exclusive merchandise signed by Vllow elite ambassadors.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    HStack(spacing: 6) {
                        Text("EXPLORE SERIES")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(AppTheme.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(AppTheme.cardSurface)
                .clipShape(.rect(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.border, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)

            Button {
                appState.selectedTab = .coach
            } label: {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("V-BOOST")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(AppTheme.neonGreen)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppTheme.neonGreen.opacity(0.15))
                            .clipShape(Capsule())

                        Spacer()

                        if appState.gameData.isDoubleCoinWeekend {
                            Text("ACTIVE NOW")
                                .font(.system(size: 9, weight: .bold))
                                .tracking(2)
                                .foregroundStyle(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(AppTheme.neonGreen)
                                .clipShape(Capsule())
                        }
                    }

                    Text("Double Coin\nWeekend")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(AppTheme.neonGreen)
                        .lineSpacing(2)

                    Text("Earn 2x V-Coins for every AI Session completed this weekend.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    HStack(spacing: 6) {
                        Text("START SESSION")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2)
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(AppTheme.neonGreen)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.08, green: 0.1, blue: 0.07), AppTheme.darkBg],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(.rect(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.neonGreen.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .light), trigger: appState.selectedTab)
        }
    }
}
