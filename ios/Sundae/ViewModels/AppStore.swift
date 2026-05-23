import Foundation
import SwiftUI

@Observable
final class AppStore {
    // Persistence keys
    private let kProfile = "sundae.profile"
    private let kPlan = "sundae.plan"
    private let kPantry = "sundae.pantry"
    private let kCompletedSlots = "sundae.completedSlots"
    private let kCheckedItems = "sundae.checkedGrocery"
    private let kCompletedSteps = "sundae.completedPrep"
    private let kOnboarded = "sundae.onboarded"

    // State
    var onboarded: Bool = false
    var profile = UserProfile()
    var plan = MealPlan(weekStartDate: Date().startOfWeek(), slots: [])
    var pantry: [PantryItem] = []
    var completedSlots: Set<UUID> = []
    var checkedGroceryItems: Set<String> = []      // ingredientId
    var completedPrepSteps: Set<String> = []       // "recipeId#stepIndex"

    init() { load() }

    // MARK: - Persistence

    func load() {
        let d = UserDefaults.standard
        onboarded = d.bool(forKey: kOnboarded)
        if let data = d.data(forKey: kProfile),
           let p = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = p
        }
        if let data = d.data(forKey: kPlan),
           let p = try? JSONDecoder().decode(MealPlan.self, from: data) {
            plan = p
        }
        if let data = d.data(forKey: kPantry),
           let p = try? JSONDecoder().decode([PantryItem].self, from: data) {
            pantry = p
        }
        if let arr = d.stringArray(forKey: kCompletedSlots) {
            completedSlots = Set(arr.compactMap(UUID.init(uuidString:)))
        }
        if let arr = d.stringArray(forKey: kCheckedItems) {
            checkedGroceryItems = Set(arr)
        }
        if let arr = d.stringArray(forKey: kCompletedSteps) {
            completedPrepSteps = Set(arr)
        }
    }

    func save() {
        let d = UserDefaults.standard
        d.set(onboarded, forKey: kOnboarded)
        if let data = try? JSONEncoder().encode(profile) { d.set(data, forKey: kProfile) }
        if let data = try? JSONEncoder().encode(plan)    { d.set(data, forKey: kPlan) }
        if let data = try? JSONEncoder().encode(pantry)  { d.set(data, forKey: kPantry) }
        d.set(completedSlots.map(\.uuidString), forKey: kCompletedSlots)
        d.set(Array(checkedGroceryItems), forKey: kCheckedItems)
        d.set(Array(completedPrepSteps), forKey: kCompletedSteps)
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        onboarded = true
        regeneratePlan()
        save()
    }

    func resetAll() {
        onboarded = false
        profile = UserProfile()
        plan = MealPlan(weekStartDate: Date().startOfWeek(), slots: [])
        pantry = []
        completedSlots = []
        checkedGroceryItems = []
        completedPrepSteps = []
        save()
    }

    // MARK: - Plan generation

    func regeneratePlan() {
        let weekStart = Date().startOfWeek()
        let slots = PlanGenerator.generate(for: profile, weekStart: weekStart)
        plan = MealPlan(weekStartDate: weekStart, slots: slots)
        completedSlots = []
        checkedGroceryItems = []
        completedPrepSteps = []
        save()
    }

    func swapRecipe(in slotId: UUID, to recipeId: String) {
        guard let idx = plan.slots.firstIndex(where: { $0.id == slotId }) else { return }
        let slot = plan.slots[idx]
        guard let recipe = SeedData.recipeById[recipeId] else { return }
        // recompute servings so kcal fits the meal's target share
        let kcalTarget = profile.targets.kcal * slot.meal.defaultShare
        let servings = max(0.5, (kcalTarget / recipe.macrosPerServing.kcal * 2).rounded() / 2)
        plan.slots[idx].recipeId = recipeId
        plan.slots[idx].servings = servings
        save()
    }

    func setServings(_ servings: Double, for slotId: UUID) {
        guard let idx = plan.slots.firstIndex(where: { $0.id == slotId }) else { return }
        plan.slots[idx].servings = max(0.5, (servings * 2).rounded() / 2)
        save()
    }

    func toggleSlotComplete(_ slotId: UUID) {
        if completedSlots.contains(slotId) { completedSlots.remove(slotId) }
        else { completedSlots.insert(slotId) }
        save()
    }

    // MARK: - Derived

    func slots(forDay dayIndex: Int) -> [PlanSlot] {
        plan.slots.filter { $0.dayIndex == dayIndex }
            .sorted { lhsOrder($0.meal) < lhsOrder($1.meal) }
    }

    private func lhsOrder(_ m: MealType) -> Int {
        switch m { case .breakfast: 0; case .lunch: 1; case .dinner: 2; case .snack: 3 }
    }

    func macros(forDay dayIndex: Int) -> Macros {
        slots(forDay: dayIndex).reduce(Macros.zero) { acc, slot in
            guard let r = SeedData.recipeById[slot.recipeId] else { return acc }
            return acc + r.macrosPerServing * slot.servings
        }
    }

    var todayIndex: Int {
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: plan.weekStartDate, to: Date()).day ?? 0
        return max(0, min(6, days))
    }

    // MARK: - Grocery list

    struct GroceryItem: Identifiable, Hashable {
        var id: String { ingredient.id }
        let ingredient: Ingredient
        let totalQty: Double
        let neededQty: Double    // after pantry subtraction
    }

    func groceryList() -> [Aisle: [GroceryItem]] {
        var totals: [String: Double] = [:]
        for slot in plan.slots {
            guard let r = SeedData.recipeById[slot.recipeId] else { continue }
            let scale = slot.servings / Double(r.baseServings)
            for ri in r.ingredients {
                totals[ri.ingredientId, default: 0] += ri.qty * scale
            }
        }
        let pantryMap = Dictionary(uniqueKeysWithValues: pantry.map { ($0.ingredientId, $0.qty) })
        var grouped: [Aisle: [GroceryItem]] = [:]
        for (id, qty) in totals {
            guard let ing = SeedData.ingredientById[id] else { continue }
            let onHand = pantryMap[id] ?? 0
            let needed = max(0, qty - onHand)
            let item = GroceryItem(ingredient: ing, totalQty: qty, neededQty: needed)
            grouped[ing.aisle, default: []].append(item)
        }
        for k in grouped.keys {
            grouped[k]?.sort { $0.ingredient.name < $1.ingredient.name }
        }
        return grouped
    }

    func toggleGroceryChecked(_ ingredientId: String) {
        if checkedGroceryItems.contains(ingredientId) { checkedGroceryItems.remove(ingredientId) }
        else { checkedGroceryItems.insert(ingredientId) }
        save()
    }

    // MARK: - Pantry

    func togglePantry(_ ingredientId: String) {
        if let idx = pantry.firstIndex(where: { $0.ingredientId == ingredientId }) {
            pantry.remove(at: idx)
        } else {
            // Add "enough on hand" — set to a high amount so it covers needs
            pantry.append(PantryItem(ingredientId: ingredientId, qty: 99999))
        }
        save()
    }

    func hasInPantry(_ ingredientId: String) -> Bool {
        pantry.contains(where: { $0.ingredientId == ingredientId })
    }

    // MARK: - Prep plan

    /// Unique recipes used this week, sorted by appearance order.
    var prepRecipes: [(recipe: Recipe, totalServings: Double)] {
        var totals: [String: Double] = [:]
        var order: [String] = []
        for slot in plan.slots {
            if totals[slot.recipeId] == nil { order.append(slot.recipeId) }
            totals[slot.recipeId, default: 0] += slot.servings
        }
        return order.compactMap { id in
            guard let r = SeedData.recipeById[id] else { return nil }
            return (r, totals[id] ?? 0)
        }
    }

    func togglePrepStep(_ key: String) {
        if completedPrepSteps.contains(key) { completedPrepSteps.remove(key) }
        else { completedPrepSteps.insert(key) }
        save()
    }
}

// MARK: - Plan Generator

enum PlanGenerator {
    /// Build a 7-day plan that fits the user's macro/diet targets.
    /// Deterministic: same inputs produce the same plan within a week.
    static func generate(for profile: UserProfile, weekStart: Date) -> [PlanSlot] {
        let recipes = SeedData.recipes.filter { suitable(for: profile, recipe: $0) }
        guard !recipes.isEmpty else { return [] }

        var slots: [PlanSlot] = []
        let meals: [MealType] = [.breakfast, .lunch, .dinner]

        for day in 0..<7 {
            for meal in meals {
                let target = profile.targets.kcal * meal.defaultShare
                let candidates = recipes.filter { $0.suitableMeals.contains(meal) }
                guard !candidates.isEmpty else { continue }
                // Seeded pick for variety: rotate by (day + mealIndex)
                let mealIndex = meals.firstIndex(of: meal) ?? 0
                let rotated = candidates.enumerated().map { (offset, recipe) -> (Recipe, Double) in
                    let diff = abs(recipe.macrosPerServing.kcal - target)
                    // Light variety penalty so the same recipe isn't picked daily
                    let seedJitter = Double((day * 7 + mealIndex * 3 + offset) % 11) * 6
                    return (recipe, diff + seedJitter)
                }
                let best = rotated.min(by: { $0.1 < $1.1 })!.0
                // Servings: 0.5 step, hit the meal kcal target
                let servings = max(0.5, (target / best.macrosPerServing.kcal * 2).rounded() / 2)
                slots.append(PlanSlot(dayIndex: day, meal: meal,
                                      recipeId: best.id, servings: servings))
            }
        }
        return slots
    }

    private static func suitable(for profile: UserProfile, recipe: Recipe) -> Bool {
        // Diet
        if let diet = profile.diet {
            switch diet {
            case .vegan:
                if !recipe.tags.contains(.vegan) { return false }
            case .vegetarian:
                if !(recipe.tags.contains(.vegetarian) || recipe.tags.contains(.vegan)) { return false }
            case .pescatarian:
                let okTags: Set<DietTag> = [.vegan, .vegetarian, .pescatarian]
                if !recipe.tags.contains(where: { okTags.contains($0) }) { return false }
            default: break
            }
        }
        // Allergies
        for allergy in profile.allergies {
            if violates(allergy: allergy, recipe: recipe) { return false }
        }
        return true
    }

    private static func violates(allergy: Allergy, recipe: Recipe) -> Bool {
        let ids = Set(recipe.ingredients.map(\.ingredientId))
        switch allergy {
        case .gluten:    return ids.intersection(["pasta","tortilla","sourdough","oats"]).isEmpty == false
        case .dairy:     return ids.intersection(["greekyog","cheddar","feta","milk","parmesan","cottage"]).isEmpty == false
        case .nuts:      return ids.intersection(["almonds","peanutbutter"]).isEmpty == false
        case .soy:       return ids.intersection(["soysauce","tofu","edamame"]).isEmpty == false
        case .shellfish: return ids.contains("shrimp")
        case .eggs:      return ids.contains("eggs")
        }
    }
}
