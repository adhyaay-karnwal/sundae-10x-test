import SwiftUI

struct RecipeDetailView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let recipe: Recipe
    var slotId: UUID? = nil

    @State private var servings: Double = 1

    var body: some View {
        Group {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        poster
                        header
                        macroBlock
                        servingsBlock
                        ingredientsBlock
                        stepsBlock
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 80)
                }
                .background(Theme.background)
                .scrollContentBackground(.hidden)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Close") { dismiss() }
                    }
                    if let slotId, store.plan.slots.contains(where: { $0.id == slotId }) {
                        ToolbarItem(placement: .bottomBar) {
                            Button {
                                store.setServings(servings, for: slotId)
                                store.toggleSlotComplete(slotId)
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: store.completedSlots.contains(slotId)
                                          ? "arrow.uturn.left.circle.fill" : "checkmark.circle.fill")
                                    Text(store.completedSlots.contains(slotId) ? "Mark not eaten" : "Mark eaten")
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                }
                .onAppear {
                    if let slotId, let slot = store.plan.slots.first(where: { $0.id == slotId }) {
                        servings = slot.servings
                    } else {
                        servings = Double(recipe.baseServings)
                    }
                }
            }
        }
        .trackView("RecipeDetailView")
    }

    // MARK: -

    private var poster: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [
                Color(hue: recipe.accentHue, saturation: 0.40, brightness: 0.35),
                Color(hue: recipe.accentHue, saturation: 0.22, brightness: 0.14)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)

            Image(systemName: recipe.glyph)
                .font(.system(size: 140, weight: .semibold))
                .foregroundStyle(Theme.text.opacity(0.12))
                .offset(x: 110, y: 30)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(recipe.tags.prefix(2), id: \.self) { t in
                        Text(t.label.uppercased())
                            .font(.mono(9, weight: .bold)).tracking(1.2)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(.black.opacity(0.35)))
                            .foregroundStyle(Theme.text)
                    }
                }
                Text(recipe.title)
                    .font(.display(24, weight: .heavy))
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)
            }
            .padding(18)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Theme.stroke, lineWidth: 1)
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.blurb)
                .font(.system(size: 15)).foregroundStyle(Theme.textDim)
            HStack(spacing: 14) {
                IconStat(icon: "clock", value: "\(recipe.timeMinutes) min")
                IconStat(icon: "person.2.fill", value: "\(recipe.baseServings) base")
                IconStat(icon: "flame.fill", value: "\(Int(recipe.macrosPerServing.kcal)) kcal/serv")
            }
        }
    }

    private var macroBlock: some View {
        let m = recipe.macrosPerServing * servings
        return SurfaceCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("PER \(String(format: "%.1f", servings).replacingOccurrences(of: ".0", with: "")) SERVING\(servings > 1 ? "S" : "")")
                        .font(.mono(10, weight: .bold)).tracking(1.2)
                        .foregroundStyle(Theme.textDim)
                    Spacer()
                    Text("\(Int(m.kcal)) kcal")
                        .font(.numeric(14, weight: .bold))
                        .foregroundStyle(Theme.accent)
                }
                HStack(spacing: 10) {
                    MacroBar(value: m.protein, target: max(1, recipe.macrosPerServing.protein * 1.5),
                             label: "protein", color: Theme.proteinColor)
                    MacroBar(value: m.carbs, target: max(1, recipe.macrosPerServing.carbs * 1.5),
                             label: "carbs", color: Theme.carbsColor)
                    MacroBar(value: m.fat, target: max(1, recipe.macrosPerServing.fat * 1.5),
                             label: "fat", color: Theme.fatColor)
                }
            }
        }
    }

    private var servingsBlock: some View {
        SurfaceCard(padding: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SERVINGS").font(.mono(10, weight: .bold)).tracking(1.2)
                        .foregroundStyle(Theme.textDim)
                    Text(String(format: "%.1f", servings))
                        .font(.numeric(28, weight: .bold))
                        .foregroundStyle(Theme.text)
                }
                Spacer()
                HStack(spacing: 8) {
                    Button {
                        servings = max(0.5, servings - 0.5)
                        if let slotId { store.setServings(servings, for: slotId) }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.text)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Theme.surfaceHi))
                    }.buttonStyle(.plain)
                    Button {
                        servings = min(8, servings + 0.5)
                        if let slotId { store.setServings(servings, for: slotId) }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.accentInk)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Theme.accent))
                    }.buttonStyle(.plain)
                }
            }
        }
    }

    private var ingredientsBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(title: "Ingredients", trailing: "scaled")
            VStack(spacing: 6) {
                ForEach(recipe.ingredients, id: \.ingredientId) { ri in
                    if let ing = SeedData.ingredientById[ri.ingredientId] {
                        let scaled = ri.qty * (servings / Double(recipe.baseServings))
                        HStack {
                            Image(systemName: ing.aisle.symbol)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.textFaint)
                                .frame(width: 18)
                            Text(ing.name)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(Theme.text)
                            Spacer()
                            Text(formatQty(scaled, unit: ing.unit))
                                .font(.numeric(13, weight: .semibold))
                                .foregroundStyle(Theme.textDim)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.surface))
                    }
                }
            }
        }
    }

    private var stepsBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(title: "Steps", trailing: "\(recipe.steps.count) steps")
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { i, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(i + 1)")
                            .font(.numeric(13, weight: .bold))
                            .foregroundStyle(Theme.accentInk)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Theme.accent))
                        Text(step)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(Theme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface))
                }
            }
        }
    }
}

private struct IconStat: View {
    let icon: String
    let value: String
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.textFaint)
            Text(value).font(.mono(11, weight: .semibold))
                .foregroundStyle(Theme.text)
        }
    }
}

func formatQty(_ q: Double, unit: String) -> String {
    if unit == "ea" || unit == "can" || unit == "slice" || unit == "tbsp" || unit == "tsp" || unit == "scoop" || unit == "bunch" {
        let rounded = (q * 2).rounded() / 2
        let str = rounded.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(rounded))" : String(format: "%.1f", rounded)
        return "\(str) \(unit)"
    }
    return "\(Int(q.rounded())) \(unit)"
}
