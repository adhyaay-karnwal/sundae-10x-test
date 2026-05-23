import SwiftUI

struct ProfileView: View {
    @Environment(AppStore.self) private var store
    @State private var showResetConfirm = false

    var body: some View {
        Group {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        identityCard
                        targetsCard
                        dietCard
                        prepCard
                        dangerZone
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 40)
                    .padding(.top, 4)
                }
                .background(Theme.background)
                .scrollContentBackground(.hidden)
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.large)
                .confirmationDialog("Reset everything?", isPresented: $showResetConfirm) {
                    Button("Reset onboarding & plan", role: .destructive) {
                        store.resetAll()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Clears your profile, plan, pantry, and progress. Used for demo only.")
                }
            }
        }
        .trackView("ProfileView")
    }

    private var identityCard: some View {
        SurfaceCard(padding: 18) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Theme.accent).frame(width: 56, height: 56)
                    Text(initials)
                        .font(.numeric(20, weight: .bold))
                        .foregroundStyle(Theme.accentInk)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.profile.name)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.text)
                    HStack(spacing: 6) {
                        Chip(text: store.profile.goal.label, symbol: "target")
                        Chip(text: store.profile.activity.label)
                    }
                }
                Spacer()
            }
        }
    }

    private var targetsCard: some View {
        SurfaceCard(padding: 18) {
            VStack(alignment: .leading, spacing: 12) {
                SectionLabel(title: "Daily targets",
                             trailing: "TDEE \(Int(store.profile.tdee.rounded())) kcal")
                HStack(alignment: .firstTextBaseline) {
                    Text("\(Int(store.profile.targets.kcal))")
                        .font(.numeric(40, weight: .bold))
                        .foregroundStyle(Theme.accent)
                    Text("kcal / day").font(.mono(12, weight: .medium))
                        .foregroundStyle(Theme.textDim)
                    Spacer()
                }
                HStack(spacing: 14) {
                    targetMini("Protein", Int(store.profile.targets.protein), Theme.proteinColor)
                    targetMini("Carbs", Int(store.profile.targets.carbs), Theme.carbsColor)
                    targetMini("Fat", Int(store.profile.targets.fat), Theme.fatColor)
                }
                Button("Regenerate plan from targets") {
                    store.regeneratePlan()
                }
                .buttonStyle(GhostButtonStyle())
            }
        }
    }

    private func targetMini(_ label: String, _ value: Int, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value)g")
                .font(.numeric(18, weight: .bold)).foregroundStyle(Theme.text)
            HStack(spacing: 4) {
                Circle().fill(color).frame(width: 6, height: 6)
                Text(label.uppercased())
                    .font(.mono(10, weight: .semibold)).tracking(1.0)
                    .foregroundStyle(Theme.textDim)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dietCard: some View {
        SurfaceCard(padding: 18) {
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel(title: "Diet & allergies")
                HStack {
                    Text(store.profile.diet?.label ?? "No restriction")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.text)
                    Spacer()
                }
                if !store.profile.allergies.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(Array(store.profile.allergies), id: \.self) { a in
                            Chip(text: a.label, symbol: "exclamationmark.triangle.fill")
                        }
                    }
                } else {
                    Text("No allergies set.")
                        .font(.system(size: 12)).foregroundStyle(Theme.textDim)
                }
            }
        }
    }

    private var prepCard: some View {
        SurfaceCard(padding: 18) {
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel(title: "Prep ritual")
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DAY").font(.mono(10, weight: .bold)).tracking(1.2)
                            .foregroundStyle(Theme.textDim)
                        Text(dayName(store.profile.prepDayWeekday))
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.text)
                    }
                    Divider().frame(height: 32).overlay(Theme.stroke)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CONTAINERS").font(.mono(10, weight: .bold)).tracking(1.2)
                            .foregroundStyle(Theme.textDim)
                        Text("\(store.profile.containerCount)")
                            .font(.numeric(18, weight: .semibold))
                            .foregroundStyle(Theme.text)
                    }
                    Spacer()
                }
            }
        }
    }

    private var dangerZone: some View {
        Button(role: .destructive) {
            showResetConfirm = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise")
                Text("Reset everything")
            }
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(Theme.warn)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.warn.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var initials: String {
        let comps = store.profile.name.split(separator: " ")
        let chars = comps.prefix(2).compactMap { $0.first }
        return chars.isEmpty ? "S" : String(chars).uppercased()
    }

    private func dayName(_ w: Int) -> String {
        ["", "Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"][safe: w] ?? "Sunday"
    }
}

private extension Array {
    subscript(safe i: Int) -> Element? { indices.contains(i) ? self[i] : nil }
}

#Preview {
    let s = AppStore(); s.completeOnboarding()
    return ProfileView().environment(s)
}
