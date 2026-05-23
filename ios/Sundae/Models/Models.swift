import Foundation
import SwiftUI

// MARK: - Macros

struct Macros: Codable, Hashable {
    var kcal: Double
    var protein: Double
    var carbs: Double
    var fat: Double

    static let zero = Macros(kcal: 0, protein: 0, carbs: 0, fat: 0)

    static func + (a: Macros, b: Macros) -> Macros {
        Macros(kcal: a.kcal + b.kcal, protein: a.protein + b.protein,
               carbs: a.carbs + b.carbs, fat: a.fat + b.fat)
    }
    static func * (m: Macros, k: Double) -> Macros {
        Macros(kcal: m.kcal * k, protein: m.protein * k, carbs: m.carbs * k, fat: m.fat * k)
    }
}

// MARK: - Aisles & Ingredients

enum Aisle: String, Codable, CaseIterable, Identifiable {
    case produce, protein, dairy, pantry, frozen, bakery, spices
    var id: String { rawValue }
    var label: String {
        switch self {
        case .produce: "Produce"
        case .protein: "Protein"
        case .dairy:   "Dairy"
        case .pantry:  "Pantry"
        case .frozen:  "Frozen"
        case .bakery:  "Bakery"
        case .spices:  "Spices"
        }
    }
    var symbol: String {
        switch self {
        case .produce: "leaf.fill"
        case .protein: "fish.fill"
        case .dairy:   "drop.fill"
        case .pantry:  "shippingbox.fill"
        case .frozen:  "snowflake"
        case .bakery:  "birthday.cake.fill"
        case .spices:  "circle.hexagongrid.fill"
        }
    }
    var sortOrder: Int {
        switch self {
        case .produce: 0; case .protein: 1; case .dairy: 2
        case .bakery: 3; case .frozen: 4; case .pantry: 5; case .spices: 6
        }
    }
}

struct Ingredient: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let aisle: Aisle
    let unit: String          // display unit (g, ml, tbsp, ea)
}

struct RecipeIngredient: Hashable, Codable {
    let ingredientId: String
    let qty: Double           // for the recipe's base servings
}

// MARK: - Recipes

enum DietTag: String, Codable, CaseIterable, Identifiable {
    case highProtein, vegetarian, vegan, pescatarian, glutenFree, dairyFree, lowCarb
    var id: String { rawValue }
    var label: String {
        switch self {
        case .highProtein: "High-protein"
        case .vegetarian:  "Vegetarian"
        case .vegan:       "Vegan"
        case .pescatarian: "Pescatarian"
        case .glutenFree:  "Gluten-free"
        case .dairyFree:   "Dairy-free"
        case .lowCarb:     "Low-carb"
        }
    }
}

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast, lunch, dinner, snack
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var symbol: String {
        switch self {
        case .breakfast: "sun.horizon.fill"
        case .lunch:     "fork.knife"
        case .dinner:    "moon.stars.fill"
        case .snack:     "leaf.fill"
        }
    }
    /// Default share of daily kcal target
    var defaultShare: Double {
        switch self {
        case .breakfast: 0.25
        case .lunch:     0.35
        case .dinner:    0.35
        case .snack:     0.05
        }
    }
}

struct Recipe: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let blurb: String
    let timeMinutes: Int
    let baseServings: Int       // macros + ingredients are sized for this many
    let macrosPerServing: Macros
    let ingredients: [RecipeIngredient]   // for baseServings
    let steps: [String]
    let tags: [DietTag]
    let suitableMeals: [MealType]
    let accentHue: Double       // 0..1, used for poster tint
    let glyph: String           // SF Symbol used as poster glyph
}

// MARK: - Plan

struct PlanSlot: Identifiable, Hashable, Codable {
    var id = UUID()
    var dayIndex: Int          // 0..6  (0 = weekStart)
    var meal: MealType
    var recipeId: String
    var servings: Double
}

struct MealPlan: Codable {
    var weekStartDate: Date
    var slots: [PlanSlot]
}

// MARK: - Pantry

struct PantryItem: Identifiable, Hashable, Codable {
    var id: String { ingredientId }
    var ingredientId: String
    var qty: Double             // amount on hand in the ingredient's unit
}

// MARK: - User Profile

enum Goal: String, Codable, CaseIterable, Identifiable {
    case cut, maintain, leanBulk
    var id: String { rawValue }
    var label: String {
        switch self {
        case .cut: "Cut"
        case .maintain: "Maintain"
        case .leanBulk: "Lean bulk"
        }
    }
    var blurb: String {
        switch self {
        case .cut: "Drop fat while keeping muscle. Slight deficit."
        case .maintain: "Hold weight. Eat at maintenance."
        case .leanBulk: "Add size with minimal fat. Slight surplus."
        }
    }
    var kcalDelta: Double {
        switch self {
        case .cut: -400; case .maintain: 0; case .leanBulk: 250
        }
    }
}

enum Sex: String, Codable, CaseIterable, Identifiable {
    case male, female
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary, light, moderate, heavy, athlete
    var id: String { rawValue }
    var label: String {
        switch self {
        case .sedentary: "Sedentary"
        case .light:     "Light (1-3 d/wk)"
        case .moderate:  "Moderate (3-5 d/wk)"
        case .heavy:     "Heavy (6+ d/wk)"
        case .athlete:   "Athlete (2x/day)"
        }
    }
    var multiplier: Double {
        switch self {
        case .sedentary: 1.2; case .light: 1.375
        case .moderate: 1.55; case .heavy: 1.725; case .athlete: 1.9
        }
    }
}

enum Allergy: String, Codable, CaseIterable, Identifiable {
    case gluten, dairy, nuts, soy, shellfish, eggs
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

struct UserProfile: Codable {
    var name: String = "Lifter"
    var sex: Sex = .male
    var age: Int = 28
    var heightCm: Int = 178
    var weightKg: Double = 80
    var activity: ActivityLevel = .moderate
    var goal: Goal = .maintain
    var targets: Macros = Macros(kcal: 2400, protein: 180, carbs: 250, fat: 75)
    var diet: DietTag? = nil
    var allergies: Set<Allergy> = []
    var prepDayWeekday: Int = 1     // 1 = Sunday (Calendar.weekday)
    var containerCount: Int = 10

    /// Mifflin-St Jeor BMR
    var bmr: Double {
        let base = 10 * weightKg + 6.25 * Double(heightCm) - 5 * Double(age)
        return sex == .male ? base + 5 : base - 161
    }
    var tdee: Double { bmr * activity.multiplier }

    /// Suggested macros from TDEE + goal
    var suggestedTargets: Macros {
        let kcal = max(1400, (tdee + goal.kcalDelta).rounded())
        // Protein: 2.0 g/kg cut, 1.8 maintain, 1.7 bulk
        let proteinPerKg: Double = goal == .cut ? 2.0 : (goal == .maintain ? 1.8 : 1.7)
        let protein = (weightKg * proteinPerKg).rounded()
        // Fat: 25% of kcal
        let fat = ((kcal * 0.25) / 9).rounded()
        // Carbs: remainder
        let remainingKcal = kcal - protein * 4 - fat * 9
        let carbs = max(0, (remainingKcal / 4)).rounded()
        return Macros(kcal: kcal, protein: protein, carbs: carbs, fat: fat)
    }

    static let preview = UserProfile()
}

// MARK: - Helpers

extension Date {
    /// Monday-start week containing this date.
    func startOfWeek(calendar: Calendar = .current) -> Date {
        var cal = calendar
        cal.firstWeekday = 2 // Monday
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return cal.date(from: comps) ?? self
    }
}

extension Calendar {
    static let weekdayNames = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    static let weekdayLong  = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
}
