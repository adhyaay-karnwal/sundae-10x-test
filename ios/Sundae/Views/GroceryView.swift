import SwiftUI

struct GroceryView: View {
    @Environment(AppStore.self) private var store
    @State private var hidePantry = true

    var body: some View {
        Group {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        summaryCard
                        aisleSections
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 40)
                    .padding(.top, 4)
                }
                .background(Theme.background)
                .scrollContentBackground(.hidden)
                .navigationTitle("Grocery")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Toggle("Hide pantry items", isOn: $hidePantry)
                            Button("Reset checked", systemImage: "arrow.counterclockwise") {
                                store.checkedGroceryItems = []
                                store.save()
                            }
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
            }
        }
        .trackView("GroceryView")
    }

    private var summaryCard: some View {
        let list = store.groceryList()
        let allItems = list.values.flatMap { $0 }
        let total = allItems.count
        let toBuy = allItems.filter { $0.neededQty > 0 }.count
        let checked = allItems.filter { store.checkedGroceryItems.contains($0.id) }.count
        let progress = total > 0 ? Double(checked) / Double(total) : 0

        return SurfaceCard(padding: 18) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("THIS WEEK").font(.mono(10, weight: .bold)).tracking(1.3)
                            .foregroundStyle(Theme.textDim)
                        Text("\(toBuy) to buy")
                            .font(.display(26, weight: .heavy))
                            .foregroundStyle(Theme.text)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(checked)/\(total)")
                            .font(.numeric(20, weight: .bold))
                            .foregroundStyle(Theme.accent)
                        Text("checked")
                            .font(.mono(10)).foregroundStyle(Theme.textFaint)
                    }
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.surfaceHi).frame(height: 6)
                        Capsule().fill(Theme.accent)
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
    }

    private var aisleSections: some View {
        let list = store.groceryList()
        let aisles = list.keys.sorted { $0.sortOrder < $1.sortOrder }
        return VStack(alignment: .leading, spacing: 16) {
            ForEach(aisles, id: \.self) { aisle in
                let items = (list[aisle] ?? []).filter { hidePantry ? $0.neededQty > 0 : true }
                if !items.isEmpty {
                    aisleSection(aisle: aisle, items: items)
                }
            }
            if list.isEmpty {
                emptyState
            }
        }
    }

    private func aisleSection(aisle: Aisle, items: [AppStore.GroceryItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: aisle.symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.accent)
                Text(aisle.label.uppercased())
                    .font(.mono(11, weight: .bold)).tracking(1.4)
                    .foregroundStyle(Theme.text)
                Spacer()
                Text("\(items.count)")
                    .font(.mono(11, weight: .semibold))
                    .foregroundStyle(Theme.textDim)
            }
            VStack(spacing: 4) {
                ForEach(items) { item in
                    GroceryRow(item: item)
                }
            }
        }
    }

    private var emptyState: some View {
        SurfaceCard {
            VStack(spacing: 8) {
                Image(systemName: "cart")
                    .font(.system(size: 28)).foregroundStyle(Theme.textFaint)
                Text("No groceries yet").font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.text)
                Text("Generate a plan on the Today tab to build your list.")
                    .font(.system(size: 12)).foregroundStyle(Theme.textDim)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 18)
        }
    }
}

private struct GroceryRow: View {
    @Environment(AppStore.self) private var store
    let item: AppStore.GroceryItem

    var body: some View {
        let checked = store.checkedGroceryItems.contains(item.id)
        let inPantry = store.hasInPantry(item.id)
        HStack(spacing: 12) {
            Button {
                store.toggleGroceryChecked(item.id)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 7).strokeBorder(Theme.stroke, lineWidth: 1)
                        .frame(width: 24, height: 24)
                    if checked {
                        RoundedRectangle(cornerRadius: 7).fill(Theme.accent)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.accentInk)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.ingredient.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(checked ? Theme.textDim : Theme.text)
                    .strikethrough(checked, color: Theme.textDim)
                if inPantry {
                    Text("In pantry").font(.mono(9, weight: .semibold)).tracking(0.8)
                        .foregroundStyle(Theme.accent)
                }
            }
            Spacer()
            Text(formatQty(item.neededQty > 0 ? item.neededQty : item.totalQty,
                           unit: item.ingredient.unit))
                .font(.numeric(13, weight: .semibold))
                .foregroundStyle(Theme.text)
            Button { store.togglePantry(item.id) } label: {
                Image(systemName: inPantry ? "shippingbox.fill" : "shippingbox")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(inPantry ? Theme.accent : Theme.textFaint)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Theme.surfaceHi))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(checked ? Theme.accent.opacity(0.4) : Theme.stroke, lineWidth: 1)
        )
        .opacity(checked ? 0.7 : 1)
    }
}

#Preview {
    let s = AppStore(); s.completeOnboarding()
    return GroceryView().environment(s)
}
