import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.timestamp, order: .reverse) var entries: [MoodEntry]
    @State private var showDeleteConfirmation = false

    private var groupedEntries: [(Date, [MoodEntry])] {
        let dictionary = Dictionary(grouping: entries) {
            Calendar.current.startOfDay(for: $0.timestamp)
        }
        return dictionary.sorted { $0.key > $1.key }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("History").font(.system(size: DesignSystem.Typography.h2, weight: .bold))
                    .foregroundStyle(MidnightTheme.accent)
                Spacer()
                if !entries.isEmpty {
                    Button("Clear All") { showDeleteConfirmation = true }
                        .font(.system(size: DesignSystem.Typography.small, weight: .bold))
                        .foregroundStyle(MidnightTheme.destructive)
                }
            }
            .padding(.horizontal).padding(.top, 60).padding(.bottom, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    if entries.isEmpty {
                        ContentUnavailableView("No history", systemImage: "tray")
                            .preferredColorScheme(.dark).padding(.top, 100)
                    } else {
                        ForEach(groupedEntries, id: \.0) { date, dayEntries in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(formatHeaderDate(date))
                                    .font(.system(size: DesignSystem.Typography.tiny, weight: .bold))
                                    .foregroundStyle(MidnightTheme.secondaryText).padding(.leading, 4)
                                ForEach(dayEntries) { entry in
                                    if let mood = Mood(rawValue: entry.moodName) {
                                        HistoryRow(mood: mood, date: entry.timestamp) {
                                            withAnimation { modelContext.delete(entry) }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(MidnightTheme.background)
        .confirmationDialog("Clear all history?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Clear All", role: .destructive) { clearAll() }
        }
    }

    private func formatHeaderDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(date: .complete, time: .omitted)
    }

    private func clearAll() {
        withAnimation { entries.forEach { modelContext.delete($0) } }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

struct HistoryRow: View {
    let mood: Mood, date: Date, onDelete: () -> Void
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: mood.icon).font(.system(size: 20))
                .foregroundStyle(mood.color).frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(mood.rawValue).font(.system(size: DesignSystem.Typography.p, weight: .bold))
                    .foregroundStyle(MidnightTheme.accent)
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: DesignSystem.Typography.tiny))
                    .foregroundStyle(MidnightTheme.secondaryText)
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "xmark").font(.system(size: 10, weight: .bold))
                    .foregroundStyle(MidnightTheme.secondaryText.opacity(0.6))
                    .padding(8).background(Circle().fill(Color.white.opacity(0.05)))
            }
        }
        .padding().background(MidnightTheme.cardBackground).cornerRadius(DesignSystem.cornerRadius)
    }
}
