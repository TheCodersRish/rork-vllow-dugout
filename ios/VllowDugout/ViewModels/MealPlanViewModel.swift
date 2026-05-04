import SwiftUI
import Foundation

@Observable
@MainActor
class MealPlanViewModel {
    var currentPlan: MealPlan?
    var selectedGoal: MealGoal = .training
    var selectedDiet: DietPreference = .omnivore
    var isGenerating = false
    var errorMessage: String?
    var savedPlans: [MealPlan] = []
    var expandedMealID: UUID?

    private let storageKey = "vllow_saved_meal_plans"
    private let dietKey = "vllow_meal_diet_preference"

    init() {
        if let raw = UserDefaults.standard.string(forKey: dietKey),
           let saved = DietPreference(rawValue: raw) {
            selectedDiet = saved
        }
        loadSavedPlans()
    }

    func setDiet(_ diet: DietPreference) {
        selectedDiet = diet
        UserDefaults.standard.set(diet.rawValue, forKey: dietKey)
    }

    func generateMealPlan() async {
        isGenerating = true
        errorMessage = nil

        let toolkitURL = Config.EXPO_PUBLIC_TOOLKIT_URL

        guard !toolkitURL.isEmpty else {
            generateFallbackPlan()
            isGenerating = false
            return
        }

        let url = URL(string: "\(toolkitURL)/agent/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let dietRules = selectedDiet.promptRules
        let prompt = """
        Generate a detailed daily cricket athlete meal plan for a "\(selectedGoal.rawValue)" day.
        DIETARY PREFERENCE: \(selectedDiet.rawValue.uppercased()).
        DIET RULES (MUST FOLLOW STRICTLY — every meal, every ingredient): \(dietRules)
        Before finalizing, double-check every ingredient list against these rules. If a meal contains a forbidden item, replace it with a compliant alternative.
        Return ONLY a valid JSON object with this exact structure (no markdown, no code fences):
        {
        "totalCalories": number,
        "totalProtein": number,
        "totalCarbs": number,
        "totalFat": number,
        "meals": [
        {
        "type": "Breakfast" or "Morning Snack" or "Lunch" or "Afternoon Snack" or "Dinner",
        "name": "meal name",
        "description": "brief description",
        "calories": number,
        "protein": number,
        "carbs": number,
        "fat": number,
        "ingredients": ["ingredient1", "ingredient2"],
        "prepTime": "X mins"
        }
        ]
        }
        Include exactly 5 meals. Make it practical and delicious. Focus on: \(selectedGoal.description).
        Reminder: STRICTLY follow the \(selectedDiet.rawValue) diet — \(dietRules)
        """

        let messages: [[String: String]] = [
            ["role": "user", "content": prompt]
        ]

        let body: [String: Any] = ["messages": messages]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: request)

            if let parsed = parseAIResponse(data) {
                currentPlan = parsed
                savePlan(parsed)
            } else {
                generateFallbackPlan()
            }
        } catch {
            generateFallbackPlan()
        }

        isGenerating = false
    }

    private func parseAIResponse(_ data: Data) -> MealPlan? {
        guard let raw = String(data: data, encoding: .utf8) else { return nil }

        var fullText = ""
        let lines = raw.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("0:\"") && trimmed.hasSuffix("\"") {
                let start = trimmed.index(trimmed.startIndex, offsetBy: 3)
                let end = trimmed.index(trimmed.endIndex, offsetBy: -1)
                let chunk = String(trimmed[start..<end])
                    .replacingOccurrences(of: "\\n", with: "\n")
                    .replacingOccurrences(of: "\\\"", with: "\"")
                    .replacingOccurrences(of: "\\t", with: "")
                fullText += chunk
            }
        }

        guard !fullText.isEmpty else { return nil }

        var jsonString = fullText
        if let jsonStart = jsonString.firstIndex(of: "{"),
           let jsonEnd = jsonString.lastIndex(of: "}") {
            jsonString = String(jsonString[jsonStart...jsonEnd])
        }

        guard let jsonData = jsonString.data(using: .utf8) else { return nil }

        do {
            let decoded = try JSONDecoder().decode(AIGeneratedMealPlan.self, from: jsonData)
            let meals = decoded.meals.map { aiMeal in
                let mealType = MealType(rawValue: aiMeal.type) ?? .lunch
                return Meal(
                    type: mealType,
                    name: aiMeal.name,
                    description: aiMeal.description,
                    calories: aiMeal.calories,
                    protein: aiMeal.protein,
                    carbs: aiMeal.carbs,
                    fat: aiMeal.fat,
                    ingredients: aiMeal.ingredients,
                    prepTime: aiMeal.prepTime
                )
            }

            let filtered = filterMealsForDiet(meals)
            return MealPlan(
                goal: selectedGoal,
                diet: selectedDiet,
                meals: filtered,
                totalCalories: decoded.totalCalories,
                totalProtein: decoded.totalProtein,
                totalCarbs: decoded.totalCarbs,
                totalFat: decoded.totalFat
            )
        } catch {
            return nil
        }
    }

    private func filterMealsForDiet(_ meals: [Meal]) -> [Meal] {
        let forbidden = forbiddenKeywords(for: selectedDiet)
        guard !forbidden.isEmpty else { return meals }
        return meals.map { meal in
            let hasForbidden = meal.ingredients.contains { ing in
                let lower = ing.lowercased()
                return forbidden.contains { lower.contains($0) }
            } || forbidden.contains { meal.name.lowercased().contains($0) || meal.description.lowercased().contains($0) }
            if hasForbidden {
                return swapForCompliantMeal(meal)
            }
            return meal
        }
    }

    private func forbiddenKeywords(for diet: DietPreference) -> [String] {
        switch diet {
        case .omnivore: return []
        case .vegetarian:
            return ["chicken", "beef", "steak", "pork", "bacon", "ham", "turkey", "lamb", "sausage", "salmon", "tuna", "fish", "shrimp", "prawn", "anchovy", "gelatin", "meat"]
        case .vegan:
            return ["chicken", "beef", "steak", "pork", "bacon", "ham", "turkey", "lamb", "sausage", "salmon", "tuna", "fish", "shrimp", "prawn", "anchovy", "gelatin", "meat", "egg", "milk", "cheese", "yogurt", "butter", "whey", "cream", "honey", "paneer", "casein"]
        case .pescatarian:
            return ["chicken", "beef", "steak", "pork", "bacon", "ham", "turkey", "lamb", "sausage", "meat"]
        case .halal:
            return ["pork", "bacon", "ham", "wine", "beer", "alcohol", "rum", "vodka"]
        }
    }

    private func swapForCompliantMeal(_ meal: Meal) -> Meal {
        let replacements: [DietPreference: [MealType: Meal]] = [
            .vegetarian: vegetarianFallbackMeals,
            .vegan: veganFallbackMeals,
            .pescatarian: pescatarianFallbackMeals,
            .halal: halalFallbackMeals
        ]
        if let perDiet = replacements[selectedDiet], let replacement = perDiet[meal.type] {
            return Meal(
                type: meal.type,
                name: replacement.name,
                description: replacement.description,
                calories: meal.calories,
                protein: replacement.protein,
                carbs: replacement.carbs,
                fat: replacement.fat,
                ingredients: replacement.ingredients,
                prepTime: replacement.prepTime
            )
        }
        return meal
    }

    private var vegetarianFallbackMeals: [MealType: Meal] {
        [
            .breakfast: Meal(type: .breakfast, name: "Greek Yogurt & Granola Bowl", description: "Protein-packed yogurt with berries, oats and almond butter", calories: 480, protein: 24, carbs: 62, fat: 14, ingredients: ["Greek yogurt", "Granola", "Mixed berries", "Almond butter", "Honey", "Chia seeds"], prepTime: "5 mins"),
            .morningSnack: Meal(type: .morningSnack, name: "Whey Protein Smoothie", description: "Whey protein shake with banana and peanut butter", calories: 320, protein: 30, carbs: 34, fat: 8, ingredients: ["Whey protein", "Banana", "Peanut butter", "Milk", "Cinnamon"], prepTime: "5 mins"),
            .lunch: Meal(type: .lunch, name: "Paneer Tikka Rice Bowl", description: "Grilled paneer with brown rice, chickpeas and veggies", calories: 640, protein: 38, carbs: 72, fat: 20, ingredients: ["Paneer", "Brown rice", "Chickpeas", "Bell peppers", "Onion", "Yogurt marinade", "Spices"], prepTime: "25 mins"),
            .afternoonSnack: Meal(type: .afternoonSnack, name: "Trail Mix & Cottage Cheese", description: "High-protein snack with nuts, seeds and fresh fruit", calories: 300, protein: 18, carbs: 28, fat: 14, ingredients: ["Cottage cheese", "Almonds", "Walnuts", "Pumpkin seeds", "Apple"], prepTime: "3 mins"),
            .dinner: Meal(type: .dinner, name: "Lentil & Tofu Curry", description: "Slow-cooked dal with grilled tofu and basmati rice", calories: 580, protein: 36, carbs: 68, fat: 16, ingredients: ["Red lentils", "Firm tofu", "Basmati rice", "Spinach", "Tomato", "Garlic", "Ginger", "Spices"], prepTime: "30 mins")
        ]
    }

    private var veganFallbackMeals: [MealType: Meal] {
        [
            .breakfast: Meal(type: .breakfast, name: "Overnight Oats & Berries", description: "Oats soaked in oat milk with chia, berries, and almond butter", calories: 470, protein: 18, carbs: 70, fat: 14, ingredients: ["Rolled oats", "Oat milk", "Chia seeds", "Mixed berries", "Almond butter", "Maple syrup"], prepTime: "5 mins"),
            .morningSnack: Meal(type: .morningSnack, name: "Plant Protein Shake", description: "Pea protein shake with banana and cocoa", calories: 290, protein: 25, carbs: 30, fat: 7, ingredients: ["Pea protein powder", "Banana", "Cocoa", "Almond milk", "Dates"], prepTime: "5 mins"),
            .lunch: Meal(type: .lunch, name: "Tempeh Buddha Bowl", description: "Roasted tempeh with quinoa, kale and tahini dressing", calories: 620, protein: 34, carbs: 70, fat: 22, ingredients: ["Tempeh", "Quinoa", "Kale", "Sweet potato", "Chickpeas", "Tahini", "Lemon"], prepTime: "25 mins"),
            .afternoonSnack: Meal(type: .afternoonSnack, name: "Hummus & Veggies", description: "Protein hummus with crunchy vegetables and seed crackers", calories: 280, protein: 12, carbs: 32, fat: 12, ingredients: ["Hummus", "Carrot sticks", "Cucumber", "Bell pepper", "Seed crackers"], prepTime: "3 mins"),
            .dinner: Meal(type: .dinner, name: "Black Bean & Tofu Tacos", description: "Spiced black beans and tofu in corn tortillas with avocado", calories: 560, protein: 30, carbs: 64, fat: 18, ingredients: ["Black beans", "Firm tofu", "Corn tortillas", "Avocado", "Salsa", "Lime", "Cilantro"], prepTime: "20 mins")
        ]
    }

    private var pescatarianFallbackMeals: [MealType: Meal] {
        [
            .breakfast: Meal(type: .breakfast, name: "Smoked Salmon Avocado Toast", description: "Sourdough with avocado, smoked salmon and poached egg", calories: 520, protein: 30, carbs: 40, fat: 24, ingredients: ["Sourdough", "Avocado", "Smoked salmon", "Egg", "Lemon", "Dill"], prepTime: "10 mins"),
            .morningSnack: Meal(type: .morningSnack, name: "Greek Yogurt Bowl", description: "Protein yogurt with berries and granola", calories: 290, protein: 22, carbs: 32, fat: 6, ingredients: ["Greek yogurt", "Mixed berries", "Granola", "Honey"], prepTime: "3 mins"),
            .lunch: Meal(type: .lunch, name: "Tuna Quinoa Salad", description: "Tuna with quinoa, chickpeas, cucumber and lemon dressing", calories: 610, protein: 44, carbs: 60, fat: 18, ingredients: ["Tuna", "Quinoa", "Chickpeas", "Cucumber", "Cherry tomatoes", "Olive oil", "Lemon"], prepTime: "15 mins"),
            .afternoonSnack: Meal(type: .afternoonSnack, name: "Cottage Cheese & Nuts", description: "Cottage cheese with walnuts and apple slices", calories: 300, protein: 22, carbs: 22, fat: 14, ingredients: ["Cottage cheese", "Walnuts", "Apple", "Cinnamon"], prepTime: "3 mins"),
            .dinner: Meal(type: .dinner, name: "Baked Salmon & Sweet Potato", description: "Lemon-herb salmon with sweet potato and asparagus", calories: 600, protein: 42, carbs: 48, fat: 22, ingredients: ["Salmon fillet", "Sweet potato", "Asparagus", "Lemon", "Olive oil", "Garlic"], prepTime: "25 mins")
        ]
    }

    private var halalFallbackMeals: [MealType: Meal] {
        [
            .breakfast: Meal(type: .breakfast, name: "Halal Chicken & Egg Wrap", description: "Halal chicken with eggs and veggies in a whole-wheat wrap", calories: 520, protein: 38, carbs: 48, fat: 18, ingredients: ["Halal chicken breast", "Eggs", "Whole-wheat wrap", "Spinach", "Tomato", "Hummus"], prepTime: "12 mins"),
            .morningSnack: Meal(type: .morningSnack, name: "Protein Smoothie", description: "Whey protein with banana and dates", calories: 280, protein: 28, carbs: 32, fat: 6, ingredients: ["Whey protein", "Banana", "Dates", "Milk"], prepTime: "5 mins"),
            .lunch: Meal(type: .lunch, name: "Halal Beef Rice Bowl", description: "Marinated halal beef with basmati rice and salad", calories: 680, protein: 46, carbs: 70, fat: 20, ingredients: ["Halal beef strips", "Basmati rice", "Cucumber", "Tomato", "Onion", "Yogurt sauce"], prepTime: "25 mins"),
            .afternoonSnack: Meal(type: .afternoonSnack, name: "Dates & Mixed Nuts", description: "Energy-dense halal snack with cottage cheese", calories: 320, protein: 14, carbs: 36, fat: 14, ingredients: ["Medjool dates", "Almonds", "Walnuts", "Cottage cheese"], prepTime: "2 mins"),
            .dinner: Meal(type: .dinner, name: "Halal Lamb Curry", description: "Slow-cooked halal lamb with basmati and roasted veggies", calories: 620, protein: 44, carbs: 56, fat: 22, ingredients: ["Halal lamb", "Basmati rice", "Onion", "Tomato", "Garlic", "Ginger", "Spices"], prepTime: "35 mins")
        ]
    }

    func generateFallbackPlan() {
        let plans: [MealGoal: MealPlan] = [
            .training: MealPlan(
                goal: .training,
                meals: [
                    Meal(type: .breakfast, name: "Oats Power Bowl", description: "Steel-cut oats with banana, almond butter, and honey", calories: 520, protein: 18, carbs: 72, fat: 16, ingredients: ["Steel-cut oats", "Banana", "Almond butter", "Honey", "Chia seeds"], prepTime: "10 mins"),
                    Meal(type: .morningSnack, name: "Protein Smoothie", description: "Whey protein with mixed berries and Greek yogurt", calories: 280, protein: 32, carbs: 28, fat: 6, ingredients: ["Whey protein", "Mixed berries", "Greek yogurt", "Milk"], prepTime: "5 mins"),
                    Meal(type: .lunch, name: "Grilled Chicken Rice Bowl", description: "Seasoned chicken breast with brown rice and veggies", calories: 680, protein: 48, carbs: 68, fat: 18, ingredients: ["Chicken breast", "Brown rice", "Broccoli", "Bell peppers", "Olive oil", "Soy sauce"], prepTime: "25 mins"),
                    Meal(type: .afternoonSnack, name: "Trail Mix & Fruit", description: "Mixed nuts with dried fruits and dark chocolate", calories: 320, protein: 10, carbs: 36, fat: 18, ingredients: ["Almonds", "Cashews", "Dried cranberries", "Dark chocolate chips", "Apple"], prepTime: "2 mins"),
                    Meal(type: .dinner, name: "Salmon & Sweet Potato", description: "Grilled salmon with roasted sweet potato and greens", calories: 620, protein: 42, carbs: 52, fat: 22, ingredients: ["Salmon fillet", "Sweet potato", "Asparagus", "Lemon", "Olive oil", "Garlic"], prepTime: "30 mins"),
                ],
                totalCalories: 2420,
                totalProtein: 150,
                totalCarbs: 256,
                totalFat: 80
            ),
            .matchDay: MealPlan(
                goal: .matchDay,
                meals: [
                    Meal(type: .breakfast, name: "Energy Pancakes", description: "Whole wheat pancakes with maple syrup and berries", calories: 580, protein: 16, carbs: 88, fat: 14, ingredients: ["Whole wheat flour", "Eggs", "Milk", "Maple syrup", "Blueberries"], prepTime: "15 mins"),
                    Meal(type: .morningSnack, name: "Banana & Energy Bar", description: "Quick energy with natural sugars and complex carbs", calories: 320, protein: 8, carbs: 58, fat: 8, ingredients: ["Banana", "Granola bar", "Electrolyte drink"], prepTime: "2 mins"),
                    Meal(type: .lunch, name: "Pasta with Chicken", description: "Whole wheat pasta with lean chicken and tomato sauce", calories: 720, protein: 44, carbs: 86, fat: 16, ingredients: ["Whole wheat pasta", "Chicken breast", "Tomato sauce", "Spinach", "Parmesan"], prepTime: "20 mins"),
                    Meal(type: .afternoonSnack, name: "Rice Cakes & PB", description: "Quick-digesting carbs with healthy fats", calories: 240, protein: 8, carbs: 32, fat: 10, ingredients: ["Rice cakes", "Peanut butter", "Honey"], prepTime: "3 mins"),
                    Meal(type: .dinner, name: "Lean Steak & Potatoes", description: "Post-match recovery with iron-rich protein", calories: 680, protein: 46, carbs: 54, fat: 24, ingredients: ["Lean beef steak", "Mashed potatoes", "Green beans", "Butter"], prepTime: "25 mins"),
                ],
                totalCalories: 2540,
                totalProtein: 122,
                totalCarbs: 318,
                totalFat: 72
            ),
            .recovery: MealPlan(
                goal: .recovery,
                meals: [
                    Meal(type: .breakfast, name: "Avocado Toast & Eggs", description: "Anti-inflammatory breakfast with healthy fats", calories: 460, protein: 22, carbs: 38, fat: 24, ingredients: ["Sourdough bread", "Avocado", "Eggs", "Cherry tomatoes", "Everything seasoning"], prepTime: "10 mins"),
                    Meal(type: .morningSnack, name: "Turmeric Latte", description: "Anti-inflammatory golden milk with protein", calories: 220, protein: 14, carbs: 22, fat: 8, ingredients: ["Milk", "Turmeric", "Ginger", "Honey", "Protein powder"], prepTime: "5 mins"),
                    Meal(type: .lunch, name: "Buddha Bowl", description: "Nutrient-dense bowl with quinoa and roasted vegetables", calories: 580, protein: 28, carbs: 62, fat: 22, ingredients: ["Quinoa", "Chickpeas", "Roasted sweet potato", "Kale", "Tahini dressing"], prepTime: "20 mins"),
                    Meal(type: .afternoonSnack, name: "Greek Yogurt Parfait", description: "Probiotic-rich snack for gut health", calories: 280, protein: 20, carbs: 32, fat: 8, ingredients: ["Greek yogurt", "Granola", "Mixed berries", "Honey"], prepTime: "3 mins"),
                    Meal(type: .dinner, name: "Baked Fish & Veggies", description: "Light, omega-3 rich dinner for muscle repair", calories: 480, protein: 38, carbs: 34, fat: 18, ingredients: ["White fish fillet", "Zucchini", "Cherry tomatoes", "Lemon", "Herbs"], prepTime: "25 mins"),
                ],
                totalCalories: 2020,
                totalProtein: 122,
                totalCarbs: 188,
                totalFat: 80
            ),
            .bulking: MealPlan(
                goal: .bulking,
                meals: [
                    Meal(type: .breakfast, name: "Mega Egg Scramble", description: "High protein scramble with cheese and turkey", calories: 680, protein: 48, carbs: 28, fat: 38, ingredients: ["Eggs", "Turkey sausage", "Cheese", "Spinach", "Whole wheat toast"], prepTime: "12 mins"),
                    Meal(type: .morningSnack, name: "Mass Gainer Shake", description: "Calorie-dense shake for lean mass gains", calories: 480, protein: 40, carbs: 56, fat: 12, ingredients: ["Whey protein", "Oats", "Banana", "Peanut butter", "Milk"], prepTime: "5 mins"),
                    Meal(type: .lunch, name: "Double Chicken Burrito", description: "Protein-packed burrito bowl with extra chicken", calories: 820, protein: 58, carbs: 72, fat: 28, ingredients: ["Chicken breast", "Brown rice", "Black beans", "Salsa", "Sour cream", "Tortilla"], prepTime: "20 mins"),
                    Meal(type: .afternoonSnack, name: "Cottage Cheese & Nuts", description: "Slow-digesting casein protein with healthy fats", calories: 380, protein: 28, carbs: 18, fat: 22, ingredients: ["Cottage cheese", "Walnuts", "Almonds", "Honey"], prepTime: "3 mins"),
                    Meal(type: .dinner, name: "Beef Stir-Fry & Rice", description: "Iron and protein rich dinner for muscle growth", calories: 760, protein: 52, carbs: 68, fat: 26, ingredients: ["Beef strips", "Jasmine rice", "Broccoli", "Bell peppers", "Teriyaki sauce"], prepTime: "20 mins"),
                ],
                totalCalories: 3120,
                totalProtein: 226,
                totalCarbs: 242,
                totalFat: 126
            ),
            .lean: MealPlan(
                goal: .lean,
                meals: [
                    Meal(type: .breakfast, name: "Egg White Veggie Omelette", description: "Low calorie, high protein start", calories: 320, protein: 28, carbs: 16, fat: 14, ingredients: ["Egg whites", "Spinach", "Mushrooms", "Feta cheese", "Tomatoes"], prepTime: "10 mins"),
                    Meal(type: .morningSnack, name: "Green Protein Smoothie", description: "Low sugar smoothie packed with greens", calories: 200, protein: 24, carbs: 18, fat: 4, ingredients: ["Protein powder", "Spinach", "Cucumber", "Lemon", "Ice"], prepTime: "5 mins"),
                    Meal(type: .lunch, name: "Grilled Chicken Salad", description: "Large salad with lean protein and light dressing", calories: 420, protein: 42, carbs: 22, fat: 18, ingredients: ["Chicken breast", "Mixed greens", "Cucumber", "Cherry tomatoes", "Olive oil dressing"], prepTime: "15 mins"),
                    Meal(type: .afternoonSnack, name: "Protein Rice Cakes", description: "Light snack with tuna and rice cakes", calories: 180, protein: 22, carbs: 18, fat: 4, ingredients: ["Rice cakes", "Canned tuna", "Lemon", "Black pepper"], prepTime: "5 mins"),
                    Meal(type: .dinner, name: "Turkey & Veggie Plate", description: "Lean protein with fiber-rich vegetables", calories: 440, protein: 40, carbs: 32, fat: 16, ingredients: ["Ground turkey", "Zucchini noodles", "Marinara sauce", "Parmesan"], prepTime: "20 mins"),
                ],
                totalCalories: 1560,
                totalProtein: 156,
                totalCarbs: 106,
                totalFat: 56
            ),
        ]

        let basePlan = plans[selectedGoal] ?? plans[.training]!
        let filteredMeals = filterMealsForDiet(basePlan.meals)
        let plan = MealPlan(
            goal: basePlan.goal,
            diet: selectedDiet,
            meals: filteredMeals,
            totalCalories: basePlan.totalCalories,
            totalProtein: basePlan.totalProtein,
            totalCarbs: basePlan.totalCarbs,
            totalFat: basePlan.totalFat
        )
        currentPlan = plan
        savePlan(plan)
    }

    private func savePlan(_ plan: MealPlan) {
        savedPlans.insert(plan, at: 0)
        if savedPlans.count > 10 {
            savedPlans = Array(savedPlans.prefix(10))
        }
        if let data = try? JSONEncoder().encode(savedPlans) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadSavedPlans() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([MealPlan].self, from: data) else {
            return
        }
        savedPlans = decoded
        currentPlan = decoded.first
    }

    func deletePlan(_ plan: MealPlan) {
        savedPlans.removeAll { $0.id == plan.id }
        if currentPlan?.id == plan.id {
            currentPlan = savedPlans.first
        }
        if let data = try? JSONEncoder().encode(savedPlans) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

nonisolated private struct AIGeneratedMealPlan: Codable, Sendable {
    let totalCalories: Int
    let totalProtein: Int
    let totalCarbs: Int
    let totalFat: Int
    let meals: [AIGeneratedMeal]
}

nonisolated private struct AIGeneratedMeal: Codable, Sendable {
    let type: String
    let name: String
    let description: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let ingredients: [String]
    let prepTime: String
}
