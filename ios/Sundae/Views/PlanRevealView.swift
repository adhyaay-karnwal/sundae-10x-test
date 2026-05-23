import SwiftUI

struct PlanRevealView: View {
    @Environment(AppStore.self) private var store
    @State private var headerIn = false
    @State private var ringIn = false
    @State private var listIn = false
    @State private var ctaIn = false

    var body: some View {
        Group {
            ZStack {
                Theme.background.ignoresSafeArea()
                // Backdrop sheen
                RadialGradient(
                    colors: [Theme.accent.opacity(0.18), .clear],
                    center: .topTrailing, startRadius: 30, endRadius: 420
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        header
                            .opacity(headerIn ? 1 : 0)
                            .offset(y: headerIn ? 0 : 12)
            
                        macroSummary
                            .opacity(ringIn ? 1 : 0)
                            .scaleEffect(ringIn ? 1 : 0.96)
            
                        weekPreview
                            .opacity(listIn ? 1 : 0)
                            .offset(y: listIn ? 0 : 14)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 60)
                    .padding(.bottom, 140)
                }
            
                VStack {
                    Spacer()
                    Button {
                        store.onboarded = true
                        store.save()
                    } label: {
                        HStack {
                            Text("Start this week")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 22)
                    .padding(.bottom, 28)
                    .opacity(ctaIn ? 1 : 0)
                    .offset(y: ctaIn ? 0 : 24)
                }
            }
            .task {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) { headerIn = true }
                try? await Task.sleep(nanoseconds: 250_000_000)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { ringIn = true }
                try? await Task.sleep(nanoseconds: 250_000_000)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) { listIn = true }
                try? await Task.sleep(nanoseconds: 300_000_000)
                withAnimation(.spring(response: 0.55, dampingFraction: 0.9)) { ctaIn = true }
            }
        }
        .trackView("PlanRevealView")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                Text("YOUR FIRST WEEK")
                    .font(.mono(11, weight: .bold))
                    .tracking(1.6)
            }
            .foregroundStyle(Theme.accent)

            Text("Plan is ready.")
                .font(.display(36, weight: .heavy))
                .foregroundStyle(Theme.text)
            Text("21 meals dialed to your targets. Sunday prep + grocery list set.")
                .font(.system(size: 15))
                .foregroundStyle(Theme.textDim)
        }
    }

    private var macroSummary: some View {
        let avg = avgDayMacros()
        return SurfaceCard(padding: 20) {
            VStack(spacing: 18) {
                HStack(alignment: .top) {
                    MacroRing(value: avg.kcal, target: store.profile.targets.kcal,
                              label: "kcal/day", unit: "", size: 132, lineWidth: 11)
                    Spacer()
                    VStack(alignment: .leading, spacing: 14) {
                        MacroBar(value: avg.protein, target: store.profile.targets.protein,
                                 label: "protein", color: Theme.proteinColor)
                        MacroBar(value: avg.carbs, target: store.profile.targets.carbs,
                                 label: "carbs", color: Theme.carbsColor)
                        MacroBar(value: avg.fat, target: store.profile.targets.fat,
                                 label: "fat", color: Theme.fatColor)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var weekPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(title: "Week at a glance", trailing: "7 days")
            VStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { day in
                    DayRow(dayIndex: day)
                }
            }
        }
    }

    private func avgDayMacros() -> Macros {
        var total = Macros.zero
        for d in 0..<7 { total = total + store.macros(forDay: d) }
        return total * (1.0/7.0)
    }
}

private struct DayRow: View {
    @Environment(AppStore.self) private var store
    let dayIndex: Int

    var body: some View {
        let m = store.macros(forDay: dayIndex)
        let slots = store.slots(forDay: dayIndex)
        SurfaceCard(padding: 14, corner: 14) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Calendar.weekdayNames[dayIndex].uppercased())
                        .font(.mono(11, weight: .bold)).tracking(1.3)
                        .foregroundStyle(Theme.textDim)
                    Text("\(Int(m.kcal))")
                        .font(.numeric(22, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text("kcal")
                        .font(.mono(10, weight: .medium))
                        .foregroundStyle(Theme.textFaint)
                }
                .frame(width: 60, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(slots) { slot in
                        if let r = SeedData.recipeById[slot.recipeId] {
                            HStack(spacing: 8) {
                                Image(systemName: slot.meal.symbol)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(Theme.textFaint)
                                    .frame(width: 12)
                                Text(r.title)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Theme.text)
                                    .lineLimit(1)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}
