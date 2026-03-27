import Foundation

nonisolated struct Product: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let subtitle: String
    let category: ProductCategory
    let priceCoins: Int
    let imageURL: String
    let woodType: String
    let weight: String
    let balance: String
    let handleGrip: String
    let powerRating: Int
    let description: String

    init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        category: ProductCategory,
        priceCoins: Int,
        imageURL: String = "",
        woodType: String = "",
        weight: String = "",
        balance: String = "",
        handleGrip: String = "",
        powerRating: Int = 0,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.category = category
        self.priceCoins = priceCoins
        self.imageURL = imageURL
        self.woodType = woodType
        self.weight = weight
        self.balance = balance
        self.handleGrip = handleGrip
        self.powerRating = powerRating
        self.description = description
    }
}

nonisolated enum ProductCategory: String, CaseIterable, Sendable {
    case all = "All Gear"
    case bats = "Bats"
    case gloves = "Gloves"
    case protective = "Protective"
    case apparel = "Apparel"
}
