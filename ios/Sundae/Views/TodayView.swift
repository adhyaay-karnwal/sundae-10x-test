import SwiftUI

struct TodayView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedDay: Int = 0
    @State private var presentedRecipe: Recipe?
    @State private var presentedSlotId: UUID?

    var body: some View {
        Group {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        headerBlock
                        dayStrip
                        macroBlock
                        prepCallout
                        mealsList
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .background(Theme.background)
                .scrollContentBackground(.hidden)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button("Regenerate week", systemImage: "arrow.triangle.2.circlepath") {
                                store.regeneratePlan()
                                selectedDay = store.todayIndex
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                }
                .navigationTitle("This week")
                .navigationBarTitleDisplayMode(.large)
                .onAppear { selectedDay = store.todayIndex }
                .sheet(item: $presentedRecipe) { recipe in
                    RecipeDetailView(recipe: recipe, slotId: presentedSlotId)
                }
            }
        }
        .trackView("TodayView")
    }

    // MARK: - Pieces

    private var headerBlock: some View {
        let today = store.todayIndex
        let m = store.macros(forDay: today)
        let remaining = max(0, store.profile.targets.kcal - m.kcal)
        return HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(dayString)
                    .font(.mono(11, weight: .bold)).tracking(1.4)
                    .foregroundStyle(Theme.accent)
                Text(remaining > 0 ? "\(Int(remaining)) kcal to go" : "Day target hit")
                    .font(.display(26, weight: .heavy))
                    .foregroundStyle(Theme.text)
                Text("\(Int(m.protein))g protein · \(Int(m.carbs))g carbs · \(Int(m.fat))g fat eaten")
                    .font(.system(size: 13)).foregroundStyle(Theme.textDim)
            }
            Spacer()
        }
    }

    private var dayStrip: some View {
        let cal = Calendar.current
        return ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<7, id: \.self) { d in
                        let date = cal.date(byAdding: .day, value: d, to: store.plan.weekStartDate) ?? Date()
                        let isToday = d == store.todayIndex
                        Button { withAnimation { selectedDay = d } } label: {
                            VStack(spacing: 4) {
                                Text(Calendar.weekdayNames[d].uppercased())
                                    .font(.mono(10, weight: .semibold))
                                    .tracking(1.1)
                                Text("\(cal.component(.day, from: date))")
                                    .font(.numeric(18, weight: .bold))
                            }
                            .frame(width: 48, height: 60)
                            .foregroundStyle(selectedDay == d ? Theme.accentInk : (isToday ? Theme.text : Theme.textDim))
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(selectedDay == d ? Theme.accent : Theme.surface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(isToday && selectedDay != d ? Theme.accent : Theme.stroke,
                                                  lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .id(d)
                    }
                }
                .padding(.vertical, 2)
            }
            .onAppear { proxy.scrollTo(selectedDay, anchor: .center) }
        }
    }

    private var macroBlock: some View {
        let m = store.macros(forDay: selectedDay)
        return SurfaceCard(padding: 20) {
            HStack(alignment: .center, spacing: 16) {
                MacroRing(value: m.kcal, target: store.profile.targets.kcal,
                          label: "kcal", unit: "", size: 130, lineWidth: 12)
                VStack(spacing: 14) {
                    MacroBar(value: m.protein, target: store.profile.targets.protein,
                             label: "protein", color: Theme.proteinColor)
                    MacroBar(value: m.carbs, target: store.profile.targets.carbs,
                             label: "carbs", color: Theme.carbsColor)
                    MacroBar(value: m.fat, target: store.profile.targets.fat,
                             label: "fat", color: Theme.fatColor)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var prepCallout: some View {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let isPrepDay = weekday == store.profile.prepDayWeekday
        return SurfaceCard(padding: 16) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(Theme.accent.opacity(0.15))
                        .frame(width: 46, height: 46)
                    Image(systemName: "timer")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(isPrepDay ? "Prep day — let's go" : "Prep day this week")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.text)
                    Text("\(store.prepRecipes.count) recipes · \(estimatedPrepMinutes()) min batch")
                        .font(.system(size: 12)).foregroundStyle(Theme.textDim)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textFaint)
            }
        }
    }

    private var mealsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(title: Calendar.weekdayLong[selectedDay] + " plate", trailing: "tap to view")
            VStack(spacing: 8) {
                ForEach(store.slots(forDay: selectedDay)) { slot in
                    if let recipe = SeedData.recipeById[slot.recipeId] {
                        Button {
                            presentedSlotId = slot.id
                            presentedRecipe = recipe
                        } label: {
                            MealSlotRow(slot: slot, recipe: recipe,
                                        completed: store.completedSlots.contains(slot.id))
                        }
                        .buttonStyle(.plain)
                    }
                }
                if store.slots(forDay: selectedDay).isEmpty {
                    EmptyDayCard()
                }
            }
        }
    }

    private var dayString: String {
        let f = DateFormatter(); f.dateFormat = "EEEE · MMM d"
        let d = Calendar.current.date(byAdding: .day, value: selectedDay, to: store.plan.weekStartDate) ?? Date()
        return f.string(from: d).uppercased()
    }

    private func estimatedPrepMinutes() -> Int {
        let total = store.prepRecipes.reduce(0) { $0 + $1.recipe.timeMinutes }
        // batched: assume parallel work, ~60% of summed time
        return Int(Double(total) * 0.6)
    }
}

// MARK: - Meal Slot Row

struct MealSlotRow: View {
    @Environment(AppStore.self) private var store
    let slot: PlanSlot
    let recipe: Recipe
    let completed: Bool

    var body: some View {
        let m = recipe.macrosPerServing * slot.servings
        HStack(spacing: 12) {
            RecipePoster(recipe: recipe, size: 64)
                .overlay(alignment: .topTrailing) {
                    if completed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.accent)
                            .padding(4)
                    }
                }
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    SlotMealLabel(meal: slot.meal)
                    Text("·").foregroundStyle(Theme.textFaint)
                    Text("\(recipe.timeMinutes) min")
                        .font(.mono(10, weight: .semibold)).tracking(1.0)
                        .foregroundStyle(Theme.textDim)
                }
                Text(recipe.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                HStack(spacing: 10) {
                    StatPill(value: "\(Int(m.kcal))", label: "kcal")
                    StatPill(value: "\(Int(m.protein))g", label: "p")
                    StatPill(value: "\(Int(m.carbs))g", label: "c")
                    StatPill(value: "\(Int(m.fat))g", label: "f")
                }
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(completed ? Theme.accent.opacity(0.6) : Theme.stroke, lineWidth: 1)
        )
        .opacity(completed ? 0.7 : 1)
    }
}

struct StatPill: View {
    let value: String
    let label: String
    var body: some View {
        HStack(spacing: 3) {
            Text(value).font(.numeric(11, weight: .bold))
            Text(label).font(.mono(9, weight: .semibold)).tracking(0.6)
                .foregroundStyle(Theme.textDim)
        }
        .foregroundStyle(Theme.text)
    }
}

private struct EmptyDayCard: View {
    var body: some View {
        SurfaceCard {
            VStack(spacing: 8) {
                Image(systemName: "fork.knife.circle")
                    .font(.system(size: 28)).foregroundStyle(Theme.textFaint)
                Text("Nothing planned").font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.text)
                Text("Open Planner to add meals to this day.")
                    .font(.system(size: 12)).foregroundStyle(Theme.textDim)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
    }
}

#Preview {
    let s = AppStore(); s.completeOnboarding()
    return TodayView().environment(s)
}
