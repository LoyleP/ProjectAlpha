import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query var entries: [MoodEntry]

    var moodCounts: [(name: String, count: Int, percentage: Double, color: Color)] {
        let total = entries.count
        return Mood.allCases.map { mood in
            let count = entries.filter { $0.moodName == mood.rawValue }.count
            let percentage = total > 0 ? (Double(count) / Double(total) * 100) : 0
            return (mood.rawValue, count, percentage, mood.color)
        }.sorted { $0.count > $1.count }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Insights").font(.system(size: DesignSystem.Typography.h2, weight: .bold))
                    .foregroundStyle(MidnightTheme.accent)
                Spacer()
            }
            .padding(.horizontal).padding(.top, 60)

            ScrollView {
                VStack(alignment: .leading, spacing: 35) {
                    Text("Mood Ranking").font(.system(size: DesignSystem.Typography.h6, weight: .bold))
                        .foregroundStyle(MidnightTheme.secondaryText)
                    Chart {
                        ForEach(moodCounts, id: \.name) { item in
                            BarMark(x: .value("Mood", item.name), y: .value("Count", item.count))
                                .foregroundStyle(item.color.gradient).cornerRadius(6)
                                .annotation(position: .top, spacing: 8) {
                                    VStack(spacing: 2) {
                                        Text("\(item.count)").font(.system(size: DesignSystem.Typography.tiny, weight: .bold))
                                            .foregroundColor(MidnightTheme.accent)
                                        if item.count > 0 {
                                            Text("\(Int(item.percentage))%").font(.system(size: 8))
                                                .foregroundColor(MidnightTheme.secondaryText)
                                        }
                                    }
                                }
                        }
                    }
                    .frame(height: 300)
                    .chartXAxis {
                        AxisMarks { _ in AxisValueLabel().foregroundStyle(MidnightTheme.accent) }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisGridLine().foregroundStyle(Color.white.opacity(0.1))
                            AxisValueLabel().foregroundStyle(MidnightTheme.secondaryText)
                        }
                    }
                    if entries.count > 0 {
                        Text("Based on \(entries.count) total entries")
                            .font(.system(size: DesignSystem.Typography.tiny, weight: .medium))
                            .foregroundStyle(MidnightTheme.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .center).padding(.top, 10)
                    }
                }
                .padding()
            }
        }
        .background(MidnightTheme.background)
    }
}
