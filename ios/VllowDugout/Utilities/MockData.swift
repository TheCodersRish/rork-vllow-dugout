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

    static let mealPlanItems: [MealPlanItem] = [
        MealPlanItem(
            id: UUID(uuidString: "a1000001-0000-0000-0000-000000000001")!,
            title: "Power Oats & Berries",
            slot: .breakfast,
            category: .training,
            calories: 420,
            proteinG: 28,
            carbsG: 52,
            fatG: 12,
            highlight: "Slow carbs for a long net block without the crash.",
            imageURL: "https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=800",
            prepMinutes: 12,
            ingredients: [
                "Rolled oats 60g", "Mixed berries 100g", "Greek yogurt 150g",
                "Honey 1 tbsp", "Chia seeds 1 tbsp", "Almond milk 200ml"
            ],
            chefNotes: "Eat 90 minutes before training. Add cinnamon for steadier glucose."
        ),
        MealPlanItem(
            id: UUID(uuidString: "a1000001-0000-0000-0000-000000000002")!,
            title: "Crease Chicken Bowl",
            slot: .lunch,
            category: .training,
            calories: 640,
            proteinG: 48,
            carbsG: 55,
            fatG: 22,
            highlight: "High protein for muscle recovery after bowling workloads.",
            imageURL: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800",
            prepMinutes: 25,
            ingredients: [
                "Grilled chicken breast 180g", "Brown rice 180g cooked",
                "Roasted broccoli 120g", "Olive oil 1 tbsp", "Lemon, herbs"
            ],
            chefNotes: "Double rice on heavy batting days; dial oil back if you need a lighter gut."
        ),
        MealPlanItem(
            id: UUID(uuidString: "a1000001-0000-0000-0000-000000000003")!,
            title: "Match Eve Salmon",
            slot: .dinner,
            category: .matchDay,
            calories: 580,
            proteinG: 42,
            carbsG: 48,
            fatG: 24,
            highlight: "Omega-3s and clean carbs the night before you take the field.",
            imageURL: "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=800",
            prepMinutes: 28,
            ingredients: [
                "Salmon fillet 180g", "Sweet potato 200g", "Asparagus bundle",
                "Garlic, dill", "Extra virgin olive oil"
            ],
            chefNotes: "Keep spice mild — sleep quality matters more than flavor fireworks."
        ),
        MealPlanItem(
            id: UUID(uuidString: "a1000001-0000-0000-0000-000000000004")!,
            title: "Stadium Morning Stack",
            slot: .breakfast,
            category: .matchDay,
            calories: 510,
            proteinG: 32,
            carbsG: 58,
            fatG: 16,
            highlight: "Portable energy for early toss times and warm-ups.",
            imageURL: "https://images.unsplash.com/photo-1525351484163-7529414344d8?w=800",
            prepMinutes: 15,
            ingredients: [
                "Wholegrain toast 2 slices", "Eggs 2", "Avocado 1/2",
                "Cherry tomatoes", "Sea salt, chili flakes"
            ],
            chefNotes: "If nerves hit, swap half the toast for extra fruit."
        ),
        MealPlanItem(
            id: UUID(uuidString: "a1000001-0000-0000-0000-000000000005")!,
            title: "Recovery Lentil Dhal",
            slot: .dinner,
            category: .recovery,
            calories: 520,
            proteinG: 26,
            carbsG: 68,
            fatG: 14,
            highlight: "Anti-inflammatory spices after a heavy fielding day.",
            imageURL: "https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800",
            prepMinutes: 35,
            ingredients: [
                "Red lentils 200g dry", "Coconut milk 200ml", "Spinach 120g",
                "Turmeric, cumin, ginger", "Basmati rice 150g cooked"
            ],
            chefNotes: "Hydrate aggressively with this meal — sodium supports rehydration."
        ),
        MealPlanItem(
            id: UUID(uuidString: "a1000001-0000-0000-0000-000000000006")!,
            title: "Pavilion Protein Shake",
            slot: .snack,
            category: .recovery,
            calories: 280,
            proteinG: 32,
            carbsG: 22,
            fatG: 8,
            highlight: "30-minute post-session window — rebuild while you commute.",
            imageURL: "https://images.unsplash.com/photo-1556881286-fc6915169721?w=800",
            prepMinutes: 5,
            ingredients: [
                "Whey or plant protein 35g", "Banana 1", "Oats 30g",
                "Peanut butter 1 tbsp", "Ice, water or milk"
            ],
            chefNotes: "Blend with ice for heat days — core temp drops slightly."
        ),
        MealPlanItem(
            id: UUID(uuidString: "a1000001-0000-0000-0000-000000000007")!,
            title: "Garden Buddha Bowl",
            slot: .lunch,
            category: .vegetarian,
            calories: 560,
            proteinG: 24,
            carbsG: 72,
            fatG: 20,
            highlight: "Plant protein mix that still clears club-level training targets.",
            imageURL: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800",
            prepMinutes: 22,
            ingredients: [
                "Chickpeas 200g roasted", "Quinoa 150g cooked", "Kale 80g",
                "Tahini dressing", "Pumpkin seeds, pickled onion"
            ],
            chefNotes: "Add halloumi if you need a protein bump without meat."
        ),
        MealPlanItem(
            id: UUID(uuidString: "a1000001-0000-0000-0000-000000000008")!,
            title: "Keeper Hydration Bite",
            slot: .snack,
            category: .training,
            calories: 190,
            proteinG: 12,
            carbsG: 24,
            fatG: 6,
            highlight: "Electrolytes + quick fuel between keeping drills.",
            imageURL: "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800",
            prepMinutes: 8,
            ingredients: [
                "Rice cakes 2", "Cottage cheese 100g", "Cucumber slices",
                "Coconut water 250ml", "Pinch of sea salt"
            ],
            chefNotes: "Sip coconut water across the session — don't chug."
        ),
    ]
}
