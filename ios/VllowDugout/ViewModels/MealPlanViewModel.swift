import SwiftUI
import Foundation

@Observable
@MainActor
class MealPlanViewModel {
    var currentPlan: MealPlan?
    var selectedGoal: MealGoal = .training
    var isGenerating = false
    var errorMessage: String?
    var savedPlans: [MealPlan] = []
    var expandedMealID: UUID?

    private let storageKey = "vllow_saved_meal_plans"

    init() {
        loadSavedPlans()
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

        let prompt = """
        Generate a detailed daily cricket athlete meal plan for a "\(selectedGoal.rawValue)" day. \
        The athlete needs meals optimized for cricket performance. \
        Return ONLY a valid JSON object with this exact structure (no markdown, no code fences): \
        { \
        "totalCalories": number, \
        "totalProtein": number (grams), \
        "totalCarbs": number (grams), \
        "totalFat": number (grams), \
        "meals": [ \
        { \
        "type": "Breakfast" or "Morning Snack" or "Lunch" or "Afternoon Snack" or "Dinner", \
        "name": "meal name", \
        "description": "brief description", \
        "calories": number, \
        "protein": number, \
        "carbs": number, \
        "fat": number, \
        "ingredients": ["ingredient1", "ingredient2"], \
        "prepTime": "X mins" \
        } \
        ] \
        } \
        Include exactly 5 meals. Make it practical and delicious. Focus on: \(selectedGoal.description).
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

            return MealPlan(
                goal: selectedGoal,
                meals: meals,
                totalCalories: decoded.totalCalories,
                totalProtein: decoded.totalProtein,
                totalCarbs: decoded.totalCarbs,
                totalFat: decoded.totalFat
            )
        } catch {
            return nil
        }
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

        currentPlan = plans[selectedGoal] ?? plans[.training]!
        if let plan = currentPlan {
            savePlan(plan)
        }
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
