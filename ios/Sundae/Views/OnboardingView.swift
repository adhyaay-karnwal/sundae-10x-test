import SwiftUI

struct OnboardingView: View {
    @Environment(AppStore.self) private var store
    @State private var step: Int = 0
    @State private var draft = UserProfile()
    @State private var showingReveal = false

    private let totalSteps = 7

    var body: some View {
        Group {
            ZStack {
                Theme.background.ignoresSafeArea()
                if showingReveal {
                    PlanRevealView()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.02)),
                            removal: .opacity)
                        )
                } else {
                    quizContent
                }
            }
            .animation(.spring(response: 0.55, dampingFraction: 0.85), value: showingReveal)
            .animation(.spring(response: 0.45, dampingFraction: 0.88), value: step)
        }
        .trackView("OnboardingView")
    }

    private var quizContent: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    switch step {
                    case 0: WelcomeStep()
                    case 1: GoalStep(goal: $draft.goal)
                    case 2: StatsStep(sex: $draft.sex, age: $draft.age,
                                      heightCm: $draft.heightCm, weightKg: $draft.weightKg)
                    case 3: ActivityStep(activity: $draft.activity)
                    case 4: MacroTargetStep(draft: $draft)
                    case 5: DietStep(diet: $draft.diet, allergies: $draft.allergies)
                    case 6: PrepStep(prepDay: $draft.prepDayWeekday, containers: $draft.containerCount)
                    default: EmptyView()
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 12)
                .padding(.bottom, 120)
            }
            footer
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                if step > 0 {
                    Button {
                        step -= 1
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.textDim)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(Theme.surface))
                    }
                } else {
                    Spacer().frame(width: 34, height: 34)
                }
                Spacer()
                Text("\(step + 1) / \(totalSteps)")
                    .font(.mono(11, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(Theme.textDim)
                Spacer()
                Spacer().frame(width: 34, height: 34)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.surface).frame(height: 3)
                    Capsule().fill(Theme.accent)
                        .frame(width: geo.size.width * CGFloat(step + 1) / CGFloat(totalSteps),
                               height: 3)
                        .animation(.spring(response: 0.5), value: step)
                }
            }
            .frame(height: 3)
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
    }

    private var footer: some View {
        VStack(spacing: 12) {
            Button(action: advance) {
                HStack(spacing: 8) {
                    Text(step == totalSteps - 1 ? "Reveal my plan" : "Continue")
                    Image(systemName: step == totalSteps - 1 ? "sparkles" : "arrow.right")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
        .background(
            LinearGradient(colors: [Theme.background.opacity(0), Theme.background],
                           startPoint: .top, endPoint: .center)
                .frame(height: 80).offset(y: -40)
                .allowsHitTesting(false), alignment: .top
        )
    }

    private func advance() {
        // On step 3 (activity) -> seed macro targets
        if step == 3 {
            draft.targets = draft.suggestedTargets
        }
        if step < totalSteps - 1 {
            step += 1
        } else {
            store.profile = draft
            store.completeOnboarding()
            withAnimation { showingReveal = true }
        }
    }
}

// MARK: - Steps

private struct WelcomeStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Theme.accent)
                        .frame(width: 44, height: 44)
                    Image(systemName: "fork.knife")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Theme.accentInk)
                }
                Text("SUNDAE")
                    .font(.mono(14, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(Theme.text)
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("Plan once.\nEat right all week.")
                    .font(.display(34, weight: .heavy))
                    .foregroundStyle(Theme.text)
                Text("Tell us your targets. We'll build a 7-day plan, the grocery list, and a Sunday prep schedule that actually adds up.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Theme.textDim)
                    .fixedSize(horizontal: false, vertical: true)
            }
            VStack(spacing: 10) {
                FeatureRow(icon: "target", title: "Hits your macros",
                           subtitle: "Recipes picked to fit your kcal + protein.")
                FeatureRow(icon: "cart.fill", title: "Auto grocery list",
                           subtitle: "Grouped by aisle. Pantry subtracted.")
                FeatureRow(icon: "timer", title: "Sunday prep timeline",
                           subtitle: "Chop, roast, simmer, portion. In order.")
            }
            .padding(.top, 4)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 36, height: 36)
                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.surfaceHi))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.text)
                Text(subtitle).font(.system(size: 13)).foregroundStyle(Theme.textDim)
            }
            Spacer()
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.surface))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.stroke, lineWidth: 1))
    }
}

private struct StepHeader: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.display(28, weight: .heavy))
                .foregroundStyle(Theme.text)
            Text(subtitle)
                .font(.system(size: 15)).foregroundStyle(Theme.textDim)
        }
    }
}

private struct GoalStep: View {
    @Binding var goal: Goal
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StepHeader(title: "What are you training for?",
                       subtitle: "We'll tune your kcal and macro targets to match.")
            VStack(spacing: 10) {
                ForEach(Goal.allCases) { g in
                    Button {
                        goal = g
                    } label: {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(g.label)
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Theme.text)
                                Text(g.blurb)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.textDim)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: goal == g ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(goal == g ? Theme.accent : Theme.textFaint)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Theme.surface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(goal == g ? Theme.accent : Theme.stroke,
                                              lineWidth: goal == g ? 1.5 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct StatsStep: View {
    @Binding var sex: Sex
    @Binding var age: Int
    @Binding var heightCm: Int
    @Binding var weightKg: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StepHeader(title: "About you",
                       subtitle: "Used to calculate maintenance kcal. Stored on device.")
            VStack(alignment: .leading, spacing: 14) {
                SectionLabel(title: "Sex")
                HStack(spacing: 10) {
                    ForEach(Sex.allCases) { s in
                        Button { sex = s } label: {
                            Text(s.label)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundStyle(sex == s ? Theme.accentInk : Theme.text)
                                .background(
                                    RoundedRectangle(cornerRadius: 12).fill(sex == s ? Theme.accent : Theme.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.stroke, lineWidth: sex == s ? 0 : 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            StepperCard(label: "Age", value: Binding(get: { Double(age) },
                                                    set: { age = Int($0) }),
                        unit: "years", range: 16...80, step: 1)
            StepperCard(label: "Height", value: Binding(get: { Double(heightCm) },
                                                       set: { heightCm = Int($0) }),
                        unit: "cm", range: 140...210, step: 1)
            StepperCard(label: "Weight", value: $weightKg, unit: "kg",
                        range: 40...150, step: 0.5)
        }
    }
}

private struct StepperCard: View {
    let label: String
    @Binding var value: Double
    let unit: String
    let range: ClosedRange<Double>
    let step: Double

    var body: some View {
        SurfaceCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label.uppercased())
                        .font(.mono(11, weight: .semibold))
                        .tracking(1.3)
                        .foregroundStyle(Theme.textDim)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(step < 1 ? String(format: "%.1f", value) : "\(Int(value))")
                            .font(.numeric(28, weight: .bold))
                            .foregroundStyle(Theme.text)
                        Text(unit).font(.mono(13, weight: .medium))
                            .foregroundStyle(Theme.textDim)
                    }
                }
                Spacer()
                HStack(spacing: 10) {
                    StepBtn(symbol: "minus") {
                        value = max(range.lowerBound, value - step)
                    }
                    StepBtn(symbol: "plus") {
                        value = min(range.upperBound, value + step)
                    }
                }
            }
        }
    }
}

private struct StepBtn: View {
    let symbol: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.text)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Theme.surfaceHi))
                .overlay(Circle().strokeBorder(Theme.stroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct ActivityStep: View {
    @Binding var activity: ActivityLevel
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StepHeader(title: "Training volume?",
                       subtitle: "How often you actually move. Be honest.")
            VStack(spacing: 8) {
                ForEach(ActivityLevel.allCases) { a in
                    Button { activity = a } label: {
                        HStack {
                            Text(a.label)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.text)
                            Spacer()
                            Text("×\(String(format: "%.2f", a.multiplier))")
                                .font(.mono(12, weight: .medium))
                                .foregroundStyle(Theme.textDim)
                            Image(systemName: activity == a ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundStyle(activity == a ? Theme.accent : Theme.textFaint)
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.surface))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(activity == a ? Theme.accent : Theme.stroke,
                                              lineWidth: activity == a ? 1.5 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct MacroTargetStep: View {
    @Binding var draft: UserProfile
    @State private var useSuggested = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StepHeader(title: "Your daily targets",
                       subtitle: "Calculated from TDEE + goal. Tweak if you have your own numbers.")

            SurfaceCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("MAINTENANCE")
                            .font(.mono(11, weight: .semibold)).tracking(1.3)
                            .foregroundStyle(Theme.textDim)
                        Spacer()
                        Text("\(Int(draft.tdee.rounded())) kcal")
                            .font(.numeric(14, weight: .semibold))
                            .foregroundStyle(Theme.text)
                    }
                    Divider().overlay(Theme.stroke)
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(Int(draft.targets.kcal))")
                            .font(.numeric(46, weight: .bold))
                            .foregroundStyle(Theme.accent)
                        Text("kcal / day").font(.mono(13, weight: .medium))
                            .foregroundStyle(Theme.textDim)
                        Spacer()
                    }
                    HStack(spacing: 14) {
                        TargetMini(label: "Protein", value: Int(draft.targets.protein), color: Theme.proteinColor)
                        TargetMini(label: "Carbs", value: Int(draft.targets.carbs), color: Theme.carbsColor)
                        TargetMini(label: "Fat", value: Int(draft.targets.fat), color: Theme.fatColor)
                    }
                }
            }

            HStack(spacing: 10) {
                Button {
                    useSuggested = true
                    draft.targets = draft.suggestedTargets
                } label: {
                    Text("Use calculated")
                }
                .buttonStyle(GhostButtonStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(useSuggested ? Theme.accent : .clear, lineWidth: 1.5)
                )
            }

            VStack(spacing: 12) {
                MacroTuner(label: "kcal", value: $draft.targets.kcal, range: 1400...4000, step: 50)
                    .onChange(of: draft.targets.kcal) { _, _ in useSuggested = false }
                MacroTuner(label: "protein (g)", value: $draft.targets.protein, range: 80...300, step: 5)
                    .onChange(of: draft.targets.protein) { _, _ in useSuggested = false }
                MacroTuner(label: "carbs (g)", value: $draft.targets.carbs, range: 80...500, step: 5)
                    .onChange(of: draft.targets.carbs) { _, _ in useSuggested = false }
                MacroTuner(label: "fat (g)", value: $draft.targets.fat, range: 30...150, step: 5)
                    .onChange(of: draft.targets.fat) { _, _ in useSuggested = false }
            }
        }
    }
}

private struct TargetMini: View {
    let label: String
    let value: Int
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value)g")
                .font(.numeric(18, weight: .bold))
                .foregroundStyle(Theme.text)
            HStack(spacing: 4) {
                Circle().fill(color).frame(width: 6, height: 6)
                Text(label.uppercased())
                    .font(.mono(10, weight: .semibold)).tracking(1.0)
                    .foregroundStyle(Theme.textDim)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MacroTuner: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double

    var body: some View {
        HStack {
            Text(label.uppercased())
                .font(.mono(11, weight: .semibold)).tracking(1.2)
                .foregroundStyle(Theme.textDim)
                .frame(width: 90, alignment: .leading)
            Spacer()
            Text("\(Int(value))")
                .font(.numeric(16, weight: .semibold))
                .foregroundStyle(Theme.text)
                .frame(width: 50, alignment: .trailing)
            HStack(spacing: 8) {
                StepBtn(symbol: "minus") { value = max(range.lowerBound, value - step) }
                StepBtn(symbol: "plus") { value = min(range.upperBound, value + step) }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface))
    }
}

private struct DietStep: View {
    @Binding var diet: DietTag?
    @Binding var allergies: Set<Allergy>

    private let dietOptions: [DietTag?] = [nil, .vegetarian, .vegan, .pescatarian]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StepHeader(title: "Anything off the menu?",
                       subtitle: "We'll filter the recipe pool before generating your plan.")
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel(title: "Diet")
                FlowLayout(spacing: 8) {
                    ForEach(0..<dietOptions.count, id: \.self) { i in
                        let opt = dietOptions[i]
                        Button { diet = opt } label: {
                            Chip(text: opt?.label ?? "No restriction", selected: diet == opt)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel(title: "Allergies")
                FlowLayout(spacing: 8) {
                    ForEach(Allergy.allCases) { a in
                        Button {
                            if allergies.contains(a) { allergies.remove(a) } else { allergies.insert(a) }
                        } label: {
                            Chip(text: a.label, selected: allergies.contains(a))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct PrepStep: View {
    @Binding var prepDay: Int
    @Binding var containers: Int

    private let days = [(1,"Sun"), (2,"Mon"), (3,"Tue"), (4,"Wed"), (5,"Thu"), (6,"Fri"), (7,"Sat")]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StepHeader(title: "Prep ritual",
                       subtitle: "When you cook and how many containers you have.")
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel(title: "Prep day")
                HStack(spacing: 6) {
                    ForEach(days, id: \.0) { d in
                        Button { prepDay = d.0 } label: {
                            Text(d.1)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .foregroundStyle(prepDay == d.0 ? Theme.accentInk : Theme.text)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(prepDay == d.0 ? Theme.accent : Theme.surface)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            StepperCard(label: "Containers on hand",
                        value: Binding(get: { Double(containers) },
                                       set: { containers = Int($0) }),
                        unit: "ea", range: 4...20, step: 1)
        }
    }
}

// Minimal flow layout for chips (iOS 16+)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > maxWidth { x = 0; y += rowH + spacing; rowH = 0 }
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
        return CGSize(width: maxWidth, height: y + rowH)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX, y: CGFloat = bounds.minY, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
    }
}

#Preview {
    OnboardingView().environment(AppStore())
}
