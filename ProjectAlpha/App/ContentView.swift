// In ProjectAlpha/App/ContentView.swift

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Properties
    @State private var selectedTab = 0 // 1. Default to Home (index 0)
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    // MARK: - Initializer for Tab Bar Styling
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

    // MARK: - Main Body
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // 2. Tab 0: Home (Moved to start)
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // 3. Tab 1: Insights (Was 0, now 1)
            StatsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(1)

            // 4. Tab 2: History (Stays last)
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)
        }
        .tint(MidnightTheme.accent)
        // 5. REMOVED: .gesture(DragGesture...) block
        
        // MARK: - Onboarding Modal
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
