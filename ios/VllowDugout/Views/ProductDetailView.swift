import SwiftUI

struct ProductDetailView: View {
    let product: Product
    let appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showRedeemConfirm = false
    @State private var redeemSuccess = false
    @State private var redeemFailed = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroImage
                detailContent
            }
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.darkBg)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.darkBg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Image(systemName: "bag")
                        .foregroundStyle(AppTheme.textPrimary)
                }
            }
        }
    }

    private var heroImage: some View {
        Color(AppTheme.cardSurface)
            .aspectRatio(4/5, contentMode: .fit)
            .overlay {
                AsyncImage(url: URL(string: product.imageURL)) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                            .saturation(0.7)
                    } else {
                        Image(systemName: "sportscourt.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
                .allowsHitTesting(false)
            }
            .clipped()
            .overlay(alignment: .topTrailing) {
                Text("GRADE 1+ WILLOW")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .background(AppTheme.cardSurface.opacity(0.6))
                    .clipShape(Capsule())
                    .padding(16)
            }
    }

    private var detailContent: some View {
        VStack(spacing: 28) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("THE ELITE SANCTUARY")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(AppTheme.textSecondary)
                    Rectangle()
                        .fill(AppTheme.border)
                        .frame(width: 32, height: 1)
                }

                Text(product.name)
                    .font(.system(size: 40, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
                    .tracking(-1)

                Text("\(product.subtitle) / Elite Performance")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            pricingCTA

            if product.powerRating > 0 {
                analysisGrid
            }

            if !product.woodType.isEmpty {
                specsSection
            }

            if !product.description.isEmpty {
                performanceInsight
            }
        }
        .padding(20)
    }

    private var isRedeemed: Bool {
        appState.gameData.isRedeemed(product.id)
    }

    private var canAfford: Bool {
        appState.vCoins >= product.priceCoins
    }

    private var pricingCTA: some View {
        VStack(spacing: 20) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(product.priceCoins.formatted())")
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("V-COINS")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.neonGreen)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if isRedeemed {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.neonGreen)
                    Text("OWNED")
                        .font(.system(size: 16, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppTheme.neonGreen)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(AppTheme.neonGreen.opacity(0.1))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(AppTheme.neonGreen.opacity(0.3), lineWidth: 1)
                )
            } else if redeemSuccess {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.neonGreen)
                    Text("Redeemed Successfully!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppTheme.neonGreen)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(AppTheme.neonGreen.opacity(0.1))
                .clipShape(Capsule())
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    showRedeemConfirm = true
                } label: {
                    HStack(spacing: 10) {
                        Text("Redeem for \(product.priceCoins.formatted()) V-Coins")
                            .font(.system(size: 16, weight: .bold))
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 16))
                    }
                    .foregroundStyle(canAfford ? .black : AppTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(canAfford ? AppTheme.neonGreen : AppTheme.cardSurfaceLight)
                    .clipShape(Capsule())
                }
                .disabled(!canAfford)
                .sensoryFeedback(.impact(weight: .heavy), trigger: redeemSuccess)

                if !canAfford {
                    Text("You need \((product.priceCoins - appState.vCoins).formatted()) more V-Coins")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.goldAccent)
                }
            }

            Text("Digital asset for the Pro Elite training ecosystem")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.textTertiary)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isRedeemed ? AppTheme.neonGreen.opacity(0.3) : AppTheme.border, lineWidth: isRedeemed ? 1 : 0.5)
        )
        .confirmationDialog("Redeem \(product.name)", isPresented: $showRedeemConfirm, titleVisibility: .visible) {
            Button("Redeem for \(product.priceCoins.formatted()) V-Coins") {
                performRedeem()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You have \(appState.vCoins.formatted()) V-Coins. This will deduct \(product.priceCoins.formatted()) V-Coins from your balance.")
        }
        .alert("Not Enough V-Coins", isPresented: $redeemFailed) {
            Button("OK") {}
        } message: {
            Text("You need \((product.priceCoins - appState.vCoins).formatted()) more V-Coins to redeem this item. Complete drills and record matches to earn more!")
        }
    }

    private func performRedeem() {
        let success = appState.gameData.redeemProduct(product)
        if success {
            withAnimation(.spring(response: 0.5)) {
                redeemSuccess = true
            }
            appState.lastCoinReason = "Redeemed \(product.name)"
        } else {
            redeemFailed = true
        }
    }

    private var analysisGrid: some View {
        HStack(spacing: 12) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(AppTheme.cardSurfaceLight, lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: Double(product.powerRating) / 100.0)
                        .stroke(AppTheme.neonGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    Text("\(product.powerRating)")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                }

                Text("POWER RATING")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(AppTheme.cardSurface)
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.border, lineWidth: 0.5)
            )

            VStack(spacing: 16) {
                HStack(alignment: .bottom, spacing: 3) {
                    ForEach([0.4, 0.7, 1.0, 0.8, 0.3], id: \.self) { h in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(h == 1.0 ? AppTheme.neonGreen : AppTheme.cardSurfaceLight)
                            .frame(width: 8, height: 60 * h)
                    }
                }
                .frame(height: 60)

                Text("SWEET SPOT")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(AppTheme.cardSurface)
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.border, lineWidth: 0.5)
            )
        }
    }

    private var specsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Text("Technical Blueprint")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Rectangle()
                    .fill(AppTheme.border)
                    .frame(height: 1)
            }

            let specs: [(String, String, String)] = [
                ("leaf.fill", "WOOD TYPE", product.woodType),
                ("scalemass.fill", "WEIGHT", product.weight),
                ("arrow.left.and.right", "BALANCE", product.balance),
                ("hand.raised.fill", "HANDLE GRIP", product.handleGrip),
            ].filter { !$0.2.isEmpty }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(specs, id: \.1) { icon, label, value in
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)

                        Text(label)
                            .font(.system(size: 8, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(AppTheme.textSecondary)

                        Text(value)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
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

    private var performanceInsight: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI-Enhanced Performance")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(AppTheme.neonGreen)

            Text(product.description)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(4)

            HStack(spacing: 8) {
                tag("VELOCITY READY")
                tag("SMART CORE")
            }

            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(AppTheme.neonGreen)
                Text("AUTHENTIC ELITE GRADE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.1, blue: 0.07), AppTheme.cardSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.neonGreen.opacity(0.15), lineWidth: 1)
        )
    }

    private func tag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .tracking(2)
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.cardSurfaceLight)
            .clipShape(.rect(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.border, lineWidth: 0.5)
            )
    }
}
