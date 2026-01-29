import SwiftUI
import Charts

struct StatCard: View {
    let title: String, value: String, subtitle: String, icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: DesignSystem.Typography.tiny, weight: .bold))
                    .foregroundStyle(MidnightTheme.secondaryText)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(MidnightTheme.secondaryText)
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(value)
                    .font(.system(size: DesignSystem.Typography.h2, weight: .bold, design: .rounded))
                    .foregroundStyle(MidnightTheme.accent)
                
                Text(subtitle)
                    .font(.system(size: DesignSystem.Typography.tiny))
                    .foregroundStyle(MidnightTheme.secondaryText)
                    .padding(.bottom, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Layout remains here
        .glassEffect() // All styling is now here
    }
}

struct MoodButton: View {
    let mood: Mood, isSelected: Bool, action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: mood.icon).font(.system(size: 20))
                Text(mood.rawValue).font(.system(size: DesignSystem.Typography.tiny, weight: .bold))
            }
            .frame(maxWidth: .infinity).frame(height: 65)
            .background(isSelected ? mood.color : MidnightTheme.cardBackground.opacity(0.65))
            .foregroundStyle(isSelected ? .black : mood.color)
            .cornerRadius(12).scaleEffect(isSelected ? 1.05 : 1.0)
            .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

struct OnboardingButton: View {
    let title: String, isPrimary: Bool, action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.system(size: DesignSystem.Typography.p, weight: .bold))
                .frame(maxWidth: .infinity).frame(height: 55)
                .background(isPrimary ? MidnightTheme.accent : Color.clear)
                .foregroundStyle(isPrimary ? .black : MidnightTheme.accent)
                .cornerRadius(16).overlay(
                    RoundedRectangle(cornerRadius: 16).stroke(MidnightTheme.accent, lineWidth: isPrimary ? 0 : 1)
                )
        }
    }
}

// In CommonComponents.swift
struct MoodCarouselItem: View {
    let mood: Mood
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                // Glow effect behind the icon when selected
                if isSelected {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .blur(radius: 5)
                }
                
                Image(systemName: mood.icon)
                    .font(.system(size: isSelected ? 36 : 28)) // Larger icon
                    .foregroundStyle(isSelected ? .white : mood.color)
                    .contentTransition(.symbolEffect(.replace)) // iOS 17 symbol animation
            }
            
            Text(mood.rawValue.capitalized)
                .font(.system(size: isSelected ? 20 : 16, weight: .bold, design: .rounded))
                .foregroundStyle(isSelected ? .white : MidnightTheme.secondaryText)
        }
        .frame(maxWidth: .infinity) // Fill the container frame provided by HomeView
        .frame(height: 220)
        .background(
            ZStack {
                Capsule()
                    .fill(isSelected ? mood.color : MidnightTheme.cardBackground.opacity(0.65)) // More transparent when idle
                
                if !isSelected {
                    Capsule()
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }
            }
        )
        // Only show strong shadow on the selected item
        .shadow(color: isSelected ? mood.color.opacity(0.5) : .clear, radius: 20, y: 10)
    }
}

enum ChartTimeRange: String, CaseIterable {
    case week = "7 Days"
    case month = "30 Days"
}

struct MoodChart: View {
    let entries: [MoodEntry]
    @State private var timeRange: ChartTimeRange = .week
    
    // Filter entries based on selected range
    var filteredEntries: [MoodEntry] {
        let days = timeRange == .week ? 7 : 30
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        return entries
            .filter { $0.timestamp >= cutoffDate }
            .sorted { $0.timestamp < $1.timestamp }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with Selector
            HStack {
                Text("Mood Trends")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MidnightTheme.secondaryText)
                
                Spacer()
                
                // Custom Segmented Picker
                HStack(spacing: 0) {
                    ForEach(ChartTimeRange.allCases, id: \.self) { range in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                timeRange = range
                            }
                        }) {
                            Text(range.rawValue)
                                .font(.system(size: 12, weight: .bold))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    ZStack {
                                        if timeRange == range {
                                            Capsule()
                                                .fill(MidnightTheme.accent)
                                                .matchedGeometryEffect(id: "RANGE_TAB", in: animationNamespace)
                                        }
                                    }
                                )
                                .foregroundStyle(timeRange == range ? MidnightTheme.background : MidnightTheme.secondaryText)
                        }
                    }
                }
                .padding(2)
                .background(Color.white.opacity(0.05))
                .clipShape(Capsule())
            }
            
            if filteredEntries.isEmpty {
                ContentUnavailableView {
                    Label("No Data", systemImage: "chart.xyaxis.line")
                } description: {
                    Text("Log more entries to see your \(timeRange.rawValue.lowercased()) trend.")
                }
                .frame(height: 220)
                .background(MidnightTheme.cardBackground.opacity(0.3))
                .cornerRadius(16)
            } else {
                Chart {
                    ForEach(filteredEntries) { entry in
                        // Line for Mood Flow
                        LineMark(
                            x: .value("Date", entry.timestamp, unit: .day),
                            y: .value("Mood", moodValue(entry.moodName))
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(MidnightTheme.accent)
                        .symbol {
                            Circle()
                                .fill(MidnightTheme.background)
                                .stroke(MidnightTheme.accent, lineWidth: 2)
                                .frame(width: 8, height: 8)
                        }
                        
                        // Gradient Area
                        AreaMark(
                            x: .value("Date", entry.timestamp, unit: .day),
                            y: .value("Mood", moodValue(entry.moodName))
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [MidnightTheme.accent.opacity(0.2), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .chartYScale(domain: 1...5)
                .chartYAxis {
                    AxisMarks(values: [1, 3, 5]) { value in
                        if let intVal = value.as(Int.self) {
                            AxisValueLabel(moodLabel(intVal))
                                .foregroundStyle(MidnightTheme.secondaryText)
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(Color.white.opacity(0.1))
                    }
                }
                .chartXAxis {
                    // Adapt tick density based on range
                    let stride: Calendar.Component = timeRange == .week ? .day : .weekOfYear
                    
                    AxisMarks(values: .stride(by: stride)) { _ in
                        AxisValueLabel(format: .dateTime.day().month())
                            .foregroundStyle(MidnightTheme.secondaryText)
                    }
                }
                .frame(height: 220)
                .padding()
                .background(MidnightTheme.cardBackground.opacity(0.65))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
    }
    
    @Namespace private var animationNamespace
    
    private func moodValue(_ name: String) -> Int {
        switch Mood(rawValue: name) {
        case .great: return 5
        case .good: return 4
        case .neutral: return 3
        case .bad: return 2
        case .terrible: return 1
        case nil: return 3
        }
    }
    
    private func moodLabel(_ value: Int) -> String {
        switch value {
        case 5: return "Great"
        case 3: return "Okay"
        case 1: return "Awful"
        default: return ""
        }
    }
}
