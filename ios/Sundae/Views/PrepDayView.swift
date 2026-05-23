import SwiftUI

struct PrepDayView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        Group {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        overviewCard
                        timelineBlock
                        portioningBlock
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 40)
                    .padding(.top, 4)
                }
                .background(Theme.background)
                .scrollContentBackground(.hidden)
                .navigationTitle("Prep day")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            store.completedPrepSteps = []
                            store.save()
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                }
            }
        }
        .trackView("PrepDayView")
    }

    // MARK: - Pieces

    private var overviewCard: some View {
        let recipes = store.prepRecipes
        let totalTime = Int(Double(recipes.reduce(0) { $0 + $1.recipe.timeMinutes }) * 0.6)
        let totalServings = Int(recipes.reduce(0) { $0 + $1.totalServings }.rounded())
        let containers = store.profile.containerCount
        let completed = store.completedPrepSteps.count
        let totalSteps = prepGroups.reduce(0) { $0 + $1.items.count }
        let progress = totalSteps > 0 ? Double(completed) / Double(totalSteps) : 0

        return SurfaceCard(padding: 20) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("SUNDAY BATCH")
                        .font(.mono(10, weight: .bold)).tracking(1.4)
                        .foregroundStyle(Theme.accent)
                    Spacer()
                    Text("\(completed)/\(totalSteps)")
                        .font(.numeric(13, weight: .semibold)).foregroundStyle(Theme.textDim)
                }
                HStack(alignment: .firstTextBaseline) {
                    Text("\(totalTime)")
                        .font(.numeric(56, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text("min").font(.mono(14, weight: .medium))
                        .foregroundStyle(Theme.textDim)
                    Spacer()
                }
                HStack(spacing: 20) {
                    StatReadout(value: "\(recipes.count)", label: "Recipes")
                    StatReadout(value: "\(totalServings)", label: "Servings")
                    StatReadout(value: "\(containers)", label: "Containers")
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.surfaceHi).frame(height: 6)
                        Capsule().fill(Theme.accent)
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }.frame(height: 6)
            }
        }
    }

    private var timelineBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(title: "Batch timeline", trailing: "in order")
            VStack(spacing: 14) {
                ForEach(Array(prepGroups.enumerated()), id: \.offset) { idx, group in
                    PrepGroupCard(group: group, index: idx + 1)
                }
            }
        }
    }

    private var portioningBlock: some View {
        SurfaceCard(padding: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                    Text("Portion into containers")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.text)
                }
                Text("Label each container with the day and meal. Cool to room temp before sealing.")
                    .font(.system(size: 13)).foregroundStyle(Theme.textDim)
                VStack(spacing: 6) {
                    ForEach(store.prepRecipes.prefix(4), id: \.recipe.id) { r in
                        HStack {
                            RecipePoster(recipe: r.recipe, size: 32, corner: 8)
                            Text(r.recipe.title)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.text).lineLimit(1)
                            Spacer()
                            Text("× \(formatServings(r.totalServings))")
                                .font(.mono(11, weight: .semibold))
                                .foregroundStyle(Theme.textDim)
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.surfaceHi.opacity(0.5)))
                    }
                }
            }
        }
    }

    // MARK: - Derived prep groups

    struct PrepItem: Identifiable {
        let id = UUID()
        let key: String        // unique per step (for completion tracking)
        let title: String
        let detail: String
        let minutes: Int
    }
    struct PrepGroup {
        let title: String
        let symbol: String
        let items: [PrepItem]
    }

    private var prepGroups: [PrepGroup] {
        let recipes = store.prepRecipes
        var chop: [PrepItem] = []
        var roast: [PrepItem] = []
        var simmer: [PrepItem] = []
        var portion: [PrepItem] = []

        for (i, r) in recipes.enumerated() {
            // Use the recipe's step text as a friendly source
            // Heuristics: first step usually preps, second cooks, last plates
            let recipe = r.recipe
            let key = recipe.id

            chop.append(PrepItem(
                key: "\(key)#chop",
                title: "Prep — \(recipe.title)",
                detail: recipe.steps.first ?? "Mise en place ingredients.",
                minutes: max(3, recipe.timeMinutes / 5)
            ))
            if recipe.steps.count > 1 {
                let isOven = recipe.steps.dropFirst().contains(where: { $0.lowercased().contains("roast") || $0.lowercased().contains("oven") || $0.lowercased().contains("bake") })
                let cookStep = recipe.steps[1]
                let item = PrepItem(
                    key: "\(key)#cook",
                    title: "Cook — \(recipe.title)",
                    detail: cookStep,
                    minutes: max(8, recipe.timeMinutes / 2)
                )
                if isOven { roast.append(item) } else { simmer.append(item) }
            }
            portion.append(PrepItem(
                key: "\(key)#portion",
                title: "Portion — \(recipe.title)",
                detail: "Divide into \(formatServings(r.totalServings)) servings. Label with day + meal.",
                minutes: 3
            ))
            _ = i
        }
        return [
            PrepGroup(title: "Chop & mise en place", symbol: "scissors", items: chop),
            PrepGroup(title: "Oven & roast", symbol: "flame.fill", items: roast),
            PrepGroup(title: "Stove & simmer", symbol: "drop.fill", items: simmer),
            PrepGroup(title: "Portion & store", symbol: "shippingbox.fill", items: portion),
        ].filter { !$0.items.isEmpty }
    }

    private func formatServings(_ s: Double) -> String {
        let r = (s * 2).rounded() / 2
        return r.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(r))" : String(format: "%.1f", r)
    }
}

// MARK: - Prep group card

private struct PrepGroupCard: View {
    @Environment(AppStore.self) private var store
    let group: PrepDayView.PrepGroup
    let index: Int

    var body: some View {
        SurfaceCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(Theme.accent).frame(width: 28, height: 28)
                        Text("\(index)")
                            .font(.numeric(13, weight: .bold))
                            .foregroundStyle(Theme.accentInk)
                    }
                    Text(group.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.text)
                    Spacer()
                    Image(systemName: group.symbol)
                        .foregroundStyle(Theme.textFaint)
                }
                VStack(spacing: 6) {
                    ForEach(group.items) { item in
                        PrepStepRow(item: item)
                    }
                }
            }
        }
    }
}

private struct PrepStepRow: View {
    @Environment(AppStore.self) private var store
    let item: PrepDayView.PrepItem

    var body: some View {
        let done = store.completedPrepSteps.contains(item.key)
        Button {
            store.togglePrepStep(item.key)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle().strokeBorder(Theme.stroke, lineWidth: 1).frame(width: 22, height: 22)
                    if done {
                        Circle().fill(Theme.accent).frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.accentInk)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(done ? Theme.textDim : Theme.text)
                        .strikethrough(done, color: Theme.textDim)
                    Text(item.detail)
                        .font(.system(size: 12)).foregroundStyle(Theme.textDim)
                        .lineLimit(2)
                }
                Spacer()
                Text("\(item.minutes)m")
                    .font(.mono(11, weight: .semibold))
                    .foregroundStyle(Theme.textFaint)
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.surfaceHi.opacity(0.4)))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let s = AppStore(); s.completeOnboarding()
    return PrepDayView().environment(s)
}
