import Foundation

enum MockData {
    static let drills: [Drill] = [
        Drill(
            title: "The Elbow Lock Mechanism",
            subtitle: "Perfect your follow-through and find the gaps with precision. Our AI analyzed 1,000 professional strokes.",
            category: .masterclass,
            difficulty: .pro,
            durationSeconds: 252,
            targetHits: 20,
            coinReward: 50,
            imageURL: "https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800"
        ),
        Drill(
            title: "Reflex Catching: Level 2",
            subtitle: "Sharpen your reflexes with rapid ball-catching sequences designed for close fielders.",
            category: .fielding,
            difficulty: .pro,
            durationSeconds: 120,
            targetHits: 20,
            coinReward: 50,
            imageURL: "https://images.unsplash.com/photo-1624526267942-ab0ff8a3e972?w=800"
        ),
        Drill(
            title: "Yorker Precision Training",
            subtitle: "Master the death-over yorker with guided target practice and real-time accuracy feedback.",
            category: .bowling,
            difficulty: .elite,
            durationSeconds: 300,
            targetHits: 30,
            coinReward: 75,
            imageURL: "https://images.unsplash.com/photo-1580674684081-7617fbf3d745?w=800"
        ),
        Drill(
            title: "Power Pull Shot",
            subtitle: "Generate maximum bat speed through the on-side with explosive hip rotation drills.",
            category: .batting,
            difficulty: .intermediate,
            durationSeconds: 180,
            targetHits: 15,
            coinReward: 40,
            imageURL: "https://images.unsplash.com/photo-1593766788306-28561086694e?w=800"
        ),
        Drill(
            title: "Spin Detection Drill",
            subtitle: "Train your eyes to read wrist and finger spin from the bowler's hand before release.",
            category: .batting,
            difficulty: .elite,
            durationSeconds: 240,
            targetHits: 25,
            coinReward: 60,
            imageURL: "https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800"
        ),
        Drill(
            title: "Wicketkeeping Agility",
            subtitle: "Lightning-fast glove work with lateral movement drills for leg-side takes.",
            category: .wicketkeeping,
            difficulty: .pro,
            durationSeconds: 150,
            targetHits: 18,
            coinReward: 45,
            imageURL: "https://images.unsplash.com/photo-1624526267942-ab0ff8a3e972?w=800"
        )
    ]

    static let products: [Product] = [
        Product(
            name: "Vllow Pro Bat",
            subtitle: "English Willow",
            category: .bats,
            priceCoins: 5000,
            imageURL: "https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=600",
            woodType: "Premium English Willow",
            weight: "2.8 - 2.10 lbs",
            balance: "Mid-to-Low Profile",
            handleGrip: "Hybrid Spiral Pro",
            powerRating: 85,
            description: "Every Vllow Pro bat is digitally balanced for maximum energy transfer. Integration with Elite Pro sensors allows real-time swing tracking and sweet-spot optimization."
        ),
        Product(
            name: "Kinetic Gloves",
            subtitle: "Ultra Flex",
            category: .gloves,
            priceCoins: 1200,
            imageURL: "https://images.unsplash.com/photo-1624526267942-ab0ff8a3e972?w=600",
            woodType: "",
            weight: "280g",
            balance: "",
            handleGrip: "",
            powerRating: 72,
            description: "Ultra-flexible batting gloves with impact-absorbing gel padding and breathable mesh."
        ),
        Product(
            name: "Elite Pads",
            subtitle: "Impact Shield",
            category: .protective,
            priceCoins: 2500,
            imageURL: "https://images.unsplash.com/photo-1580674684081-7617fbf3d745?w=600",
            woodType: "",
            weight: "1.2 kg",
            balance: "",
            handleGrip: "",
            powerRating: 90,
            description: "Professional-grade batting pads with triple-density foam and anatomic knee roll."
        ),
        Product(
            name: "Storm Jersey",
            subtitle: "Pro Series",
            category: .apparel,
            priceCoins: 800,
            imageURL: "https://images.unsplash.com/photo-1593766788306-28561086694e?w=600",
            woodType: "",
            weight: "",
            balance: "",
            handleGrip: "",
            powerRating: 0,
            description: "Moisture-wicking performance jersey with UV protection and four-way stretch fabric."
        )
    ]

    static let baseLeaderboard: [LeaderboardEntry] = [
        LeaderboardEntry(rank: 1, playerName: "Virat K.", vCoins: 24500, drillsCompleted: 342),
        LeaderboardEntry(rank: 2, playerName: "Rohit S.", vCoins: 22100, drillsCompleted: 310),
        LeaderboardEntry(rank: 3, playerName: "Jasprit B.", vCoins: 19800, drillsCompleted: 298),
        LeaderboardEntry(rank: 4, playerName: "Shubman G.", vCoins: 18200, drillsCompleted: 276),
        LeaderboardEntry(rank: 5, playerName: "Rishabh P.", vCoins: 16900, drillsCompleted: 264),
        LeaderboardEntry(rank: 6, playerName: "KL Rahul", vCoins: 15400, drillsCompleted: 251),
        LeaderboardEntry(rank: 7, playerName: "Hardik P.", vCoins: 14200, drillsCompleted: 239),
        LeaderboardEntry(rank: 8, playerName: "Ravindra J.", vCoins: 12800, drillsCompleted: 220),
        LeaderboardEntry(rank: 9, playerName: "Mohammed S.", vCoins: 11500, drillsCompleted: 208),
        LeaderboardEntry(rank: 10, playerName: "Suryakumar Y.", vCoins: 10200, drillsCompleted: 195),
    ]

    static let randomNames: [String] = [
        "Arjun M.", "Priya D.", "Dev R.", "Ananya S.", "Kiran P.",
        "Ravi T.", "Neha K.", "Aditya B.", "Meera L.", "Sanjay V.",
        "Pooja G.", "Rahul N.", "Shreya W.", "Varun C.", "Ishaan J."
    ]

    static let opponents: [String] = [
        "Melbourne Renegades", "Sydney Thunder", "Perth Scorchers",
        "Brisbane Heat", "Adelaide Strikers", "Hobart Hurricanes",
        "Delhi Capitals", "Mumbai Indians", "Royal Challengers"
    ]

    static let scoringZones: [ScoringZone] = [
        ScoringZone(name: "Deep Mid-Wicket", runs: 24, xPosition: 0.25, yPosition: 0.3, intensity: 0.8),
        ScoringZone(name: "Cover Drive", runs: 18, xPosition: 0.7, yPosition: 0.45, intensity: 0.6),
        ScoringZone(name: "Fine Leg", runs: 15, xPosition: 0.75, yPosition: 0.7, intensity: 0.5),
        ScoringZone(name: "Square Leg", runs: 10, xPosition: 0.2, yPosition: 0.6, intensity: 0.3),
    ]

    static let dismissalPatterns: [DismissalPattern] = [
        DismissalPattern(type: "Caught", percentage: 45),
        DismissalPattern(type: "LBW", percentage: 30),
        DismissalPattern(type: "Bowled", percentage: 15),
        DismissalPattern(type: "Run Out", percentage: 10),
    ]
}
