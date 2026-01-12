import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Query(sort: \MoodEntry.timestamp, order: .reverse) var entries: [MoodEntry]
    @Binding var selectedTab: Int
    @State private var selectedMood: Mood?
    @State private var showDevSettings = false
    @State private var showNewEntrySheet = false

    var todayMood: Mood? {
        let calendar = Calendar.current
        let latestToday = entries.first { calendar.isDateInToday($0.timestamp) }
        return Mood(rawValue: latestToday?.moodName ?? "")
    }

    var topMood: String {
        let counts = NSCountedSet()
        entries.forEach { counts.add($0.moodName) }
        return counts.allObjects.max {
            counts.count(for: $0) < counts.count(for: $1)
        } as? String ?? "—"
    }

    var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        headerView
                        statsView
                        summaryView
                        
                        if showDevSettings { devSettingsView }
                        Spacer(minLength: 40)
                    }
                }
                .background(backgroundLayer)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showNewEntrySheet = true }) {
                            Image(systemName: "plus")
                                .font(.body.weight(.bold))
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        }
                    }
                }
                .sheet(isPresented: $showNewEntrySheet) {
                    NewEntryView()
                }
            }
        }
}

extension HomeView {
    
    // FIXED: Corrected font definition
    private var headerView: some View {
        Text("How are you\nfeeling today ?")
            .font(.system(.largeTitle, design: .rounded, weight: .bold)) // Corrected
            .foregroundStyle(MidnightTheme.accent)
            .padding(.horizontal)
            .padding(.top, 40)
    }
    
    private var statsView: some View {
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { selectedTab = 1 }
                }) {
                    StatCard(title: "Top Mood", value: topMood, subtitle: "Analysis", icon: "chart.bar.fill")
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { selectedTab = 1 }
                }) {
                    StatCard(title: "Total Logs", value: "\(entries.count)", subtitle: "History", icon: "clock.fill")
                }
            }
            .padding(.horizontal)
        }
    
    private var summaryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline.weight(.bold))
                .foregroundStyle(MidnightTheme.secondaryText)
                .onLongPressGesture {
                    withAnimation { showDevSettings.toggle() }
                }

            HStack(spacing: 15) {
                if let mood = todayMood {
                    Image(systemName: mood.icon)
                        .font(.title3)
                        .foregroundStyle(mood.color)
                        .transition(.identity)
                        .phaseAnimator([false, true]) { content, phase in
                            content.scaleEffect(phase ? 1.15 : 1.0)
                        } animation: { _ in .easeInOut(duration: 1.5) }

                    Text("Today, your mood was \(Text(mood.rawValue.lowercased()).foregroundStyle(mood.color).bold())")
                        .font(.body)
                        .foregroundStyle(MidnightTheme.accent)
                        .transition(.identity)
                } else {
                    Text("No mood logged yet for today.")
                        .font(.body)
                        .foregroundStyle(MidnightTheme.secondaryText)
                        .italic()
                        .transition(.identity)
                        .shimmering()
                }
            }
            .padding(DesignSystem.padding)
            .frame(maxWidth: .infinity, alignment: .leading).frame(height: 52)
            .background(MidnightTheme.cardBackground.opacity(0.65))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .animation(nil, value: todayMood)
    }
    
    private var devSettingsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1).padding(.vertical, 20)
            Text("Developer Mode Active")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.orange)
            Button(action: { hasSeenOnboarding = false }) {
                Label("Restart Onboarding", systemImage: "arrow.counterclockwise.circle")
                    .font(.caption)
                    .foregroundStyle(MidnightTheme.accent)
                    .padding().frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.05)).cornerRadius(DesignSystem.cornerRadius)
            }
        }
        .padding(.horizontal).transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var backgroundLayer: some View {
        ZStack {
            MidnightTheme.background.ignoresSafeArea()
            LinearGradient(
                colors: [
                    (selectedMood?.color ?? .clear).opacity(0.25),
                    MidnightTheme.background.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: selectedMood)
        }
    }
}
