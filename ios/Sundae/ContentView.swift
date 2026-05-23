import SwiftUI

struct ContentView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        Group {
            if !store.onboarded {
                OnboardingView()
            } else {
                RootTabView()
            }
        }
        .trackView("ContentView")
    }
}

struct RootTabView: View {
    @State private var selection: AppTab = .today

    enum AppTab: Hashable { case today, planner, grocery, prep, profile }

    var body: some View {
        TabView(selection: $selection) {
            Tab("Today", systemImage: "flame.fill", value: AppTab.today) {
                TodayView()
            }
            Tab("Planner", systemImage: "calendar", value: AppTab.planner) {
                PlannerView()
            }
            Tab("Grocery", systemImage: "cart.fill", value: AppTab.grocery) {
                GroceryView()
            }
            Tab("Prep", systemImage: "timer", value: AppTab.prep) {
                PrepDayView()
            }
            Tab("Profile", systemImage: "person.crop.circle.fill", value: AppTab.profile) {
                ProfileView()
            }
        }
        .tint(Theme.accent)
    }
}

#Preview {
    ContentView().environment(AppStore())
}
