import SwiftUI

struct PlannerView: View {
    @Environment(AppStore.self) private var store
    @State private var swapTarget: PlanSlot?
    @State private var detailRecipe: Recipe?
    @State private var detailSlotId: UUID?

    var body: some View {
        Group {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 14) {
                        weekSummary
                        ForEach(0..<7, id: \.self) { day in
                            dayCard(for: day)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 40)
                    .padding(.top, 4)
                }
                .background(Theme.background)
                .scrollContentBackground(.hidden)
                .navigationTitle("Planner")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            store.regeneratePlan()
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
                .sheet(item: $swapTarget) { slot in
                    RecipeSwapSheet(slot: slot)
                }
                .sheet(item: $detailRecipe) { r in
                    RecipeDetailView(recipe: r, slotId: detailSlotId)
                }
            }
        }
        .trackView("PlannerView")
    }

    private var weekSummary: some View {
        let avg = avgDay()
        return SurfaceCard(padding: 16) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("AVG / DAY")
                        .font(.mono(10, weight: .bold)).tracking(1.3)
                        .foregroundStyle(Theme.textDim)
                    Text("\(Int(avg.kcal))")
                        .font(.numeric(28, weight: .bold))
                        .foregroundStyle(Theme.accent)
                    Text("kcal").font(.mono(10, weight: .medium)).foregroundStyle(Theme.textFaint)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    SmallMacroBadge(label: "P", value: Int(avg.protein),
                                    target: Int(store.profile.targets.protein), color: Theme.proteinColor)
                    SmallMacroBadge(label: "C", value: Int(avg.carbs),
                                    target: Int(store.profile.targets.carbs), color: Theme.carbsColor)
                    SmallMacroBadge(label: "F", value: Int(avg.fat),
                                    target: Int(store.profile.targets.fat), color: Theme.fatColor)
                }
            }
        }
    }

    private func avgDay() -> Macros {
        var t = Macros.zero
        for d in 0..<7 { t = t + store.macros(forDay: d) }
        return t * (1.0/7.0)
    }

    private func dayCard(for day: Int) -> some View {
        let slots = store.slots(forDay: day)
        let m = store.macros(forDay: day)
        let kcalDiff = m.kcal - store.profile.targets.kcal
        let onTarget = abs(kcalDiff) < store.profile.targets.kcal * 0.07

        return SurfaceCard(padding: 14) {
            VStack(spacing: 12) {
                HStack {
                    Text(Calendar.weekdayLong[day])
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.text)
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(onTarget ? Theme.good : Theme.warn)
                            .frame(width: 6, height: 6)
                        Text("\(Int(m.kcal)) kcal")
                            .font(.numeric(13, weight: .semibold))
                            .foregroundStyle(Theme.text)
                        Text(kcalDiff >= 0 ? "+\(Int(kcalDiff))" : "\(Int(kcalDiff))")
                            .font(.mono(10, weight: .semibold))
                            .foregroundStyle(onTarget ? Theme.textDim : Theme.warn)
                    }
                }
                VStack(spacing: 6) {
                    ForEach(slots) { slot in
                        if let r = SeedData.recipeById[slot.recipeId] {
                            HStack(spacing: 10) {
                                Image(systemName: slot.meal.symbol)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Theme.textFaint)
                                    .frame(width: 16)
                                Text(r.title)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Theme.text)
                                    .lineLimit(1)
                                Spacer()
                                Text("\(Int((r.macrosPerServing * slot.servings).kcal))")
                                    .font(.numeric(11, weight: .semibold))
                                    .foregroundStyle(Theme.textDim)
                                Button {
                                    swapTarget = slot
                                } label: {
                                    Image(systemName: "arrow.left.arrow.right")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(Theme.text)
                                        .frame(width: 28, height: 28)
                                        .background(Circle().fill(Theme.surfaceHi))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 6).padding(.horizontal, 8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.surfaceHi.opacity(0.4)))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                detailSlotId = slot.id
                                detailRecipe = r
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct SmallMacroBadge: View {
    let label: String
    let value: Int
    let target: Int
    let color: Color
    var body: some View {
        HStack(spacing: 8) {
            Text(label).font(.mono(10, weight: .bold)).foregroundStyle(color)
                .frame(width: 12)
            Text("\(value)").font(.numeric(13, weight: .semibold))
                .foregroundStyle(Theme.text)
            Text("/ \(target)g").font(.mono(10)).foregroundStyle(Theme.textFaint)
        }
    }
}

// MARK: - Swap sheet

struct RecipeSwapSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let slot: PlanSlot

    @State private var search: String = ""
    @State private var filter: MealType?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 12) {
                    searchField
                    filterStrip
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredRecipes) { r in
                                Button {
                                    store.swapRecipe(in: slot.id, to: r.id)
                                    dismiss()
                                } label: {
                                    RecipeBrowseRow(recipe: r, isCurrent: r.id == slot.recipeId)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 30)
                    }
                }
                .padding(.top, 6)
            }
            .navigationTitle("Swap \(slot.meal.label)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear { filter = slot.meal }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(Theme.textDim)
            TextField("Search recipes", text: $search)
                .textFieldStyle(.plain)
                .foregroundStyle(Theme.text)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface))
        .padding(.horizontal, 18)
    }

    private var filterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button { filter = nil } label: {
                    Chip(text: "All", selected: filter == nil)
                }.buttonStyle(.plain)
                ForEach(MealType.allCases) { m in
                    Button { filter = m } label: {
                        Chip(text: m.label, selected: filter == m, symbol: m.symbol)
                    }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
        }
    }

    private var filteredRecipes: [Recipe] {
        SeedData.recipes.filter { r in
            (filter == nil || r.suitableMeals.contains(filter!)) &&
            (search.isEmpty || r.title.localizedCaseInsensitiveContains(search))
        }
    }
}

struct RecipeBrowseRow: View {
    let recipe: Recipe
    var isCurrent: Bool = false
    var body: some View {
        HStack(spacing: 12) {
            RecipePoster(recipe: recipe, size: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text("\(Int(recipe.macrosPerServing.kcal)) kcal")
                        .font(.numeric(11, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                    Text("·").foregroundStyle(Theme.textFaint)
                    Text("\(Int(recipe.macrosPerServing.protein))g P")
                        .font(.mono(10, weight: .medium)).foregroundStyle(Theme.textDim)
                    Text("·").foregroundStyle(Theme.textFaint)
                    Text("\(recipe.timeMinutes) min")
                        .font(.mono(10, weight: .medium)).foregroundStyle(Theme.textDim)
                }
            }
            Spacer()
            if isCurrent {
                Text("CURRENT")
                    .font(.mono(9, weight: .bold)).tracking(1.0)
                    .foregroundStyle(Theme.accent)
            } else {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Theme.text)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isCurrent ? Theme.accent : Theme.stroke, lineWidth: 1)
        )
    }
}

#Preview {
    let s = AppStore(); s.completeOnboarding()
    return PlannerView().environment(s)
}
