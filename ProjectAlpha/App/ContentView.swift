import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Properties
    @State private var selectedTab = 1 // Default to Home (index 1)
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
            
            // Tab 0: Insights
            StatsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(0)

            // Tab 1: Home
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(1)

            // Tab 2: History
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)
        }
        .tint(MidnightTheme.accent)
        // MARK: - Swipe Gesture Logic
        .gesture(
            DragGesture(minimumDistance: 50, coordinateSpace: .local)
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height
                    
                    // 1. Ensure the swipe is horizontal (not vertical scrolling)
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        
                        // 2. Swipe Left (Next Tab)
                        if horizontalAmount < 0 && selectedTab < 2 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab += 1
                            }
                        }
                        // 3. Swipe Right (Previous Tab)
                        else if horizontalAmount > 0 && selectedTab > 0 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab -= 1
                            }
                        }
                    }
                }
        )
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
