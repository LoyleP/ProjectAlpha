import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        
        let midnightColor = UIColor(red: 10/255, green: 12/255, blue: 20/255, alpha: 1.0)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = midnightColor
        appearance.shadowColor = .clear
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Tab 0: Home
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Tab 1: Activity (Renamed from Stats, History removed)
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "calendar")
                }
                .tag(1)
        }
        .tint(MidnightTheme.accent)
        
        // Onboarding
        .fullScreenCover(
            isPresented: .init(
                get: { !hasSeenOnboarding },
                set: { hasSeenOnboarding = !$0 }
            )
        ) {
            OnboardingView(isPresented: $hasSeenOnboarding)
        }
    }
}
