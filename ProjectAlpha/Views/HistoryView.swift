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
                Text("Activity").font(.system(size: DesignSystem.Typography.h2, weight: .bold))
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
                                    // Pass the full entry to display energy and notes
                                    HistoryRow(entry: entry) {
                                        withAnimation { modelContext.delete(entry) }
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
    let entry: MoodEntry
    let onDelete: () -> Void
    
    // Resolve the Mood enum from the string stored in the model
    private var mood: Mood? {
        Mood(rawValue: entry.moodName)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 15) {
                if let mood = mood {
                    Image(systemName: mood.icon).font(.system(size: 20))
                        .foregroundStyle(mood.color).frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mood.rawValue).font(.system(size: DesignSystem.Typography.p, weight: .bold))
                            .foregroundStyle(MidnightTheme.accent)
                        Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: DesignSystem.Typography.tiny))
                            .foregroundStyle(MidnightTheme.secondaryText)
                    }
                }
                
                Spacer()
                
                // Display Energy Level
                Text("⚡️ \(entry.energy)")
                    .font(.system(size: DesignSystem.Typography.tiny, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundStyle(MidnightTheme.accent)

                Button(action: onDelete) {
                    Image(systemName: "xmark").font(.system(size: 10, weight: .bold))
                        .foregroundStyle(MidnightTheme.secondaryText.opacity(0.6))
                        .padding(8).background(Circle().fill(Color.white.opacity(0.05)))
                }
            }
            
            // Display Note if available
            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(.system(size: DesignSystem.Typography.small))
                    .foregroundStyle(MidnightTheme.secondaryText)
                    .padding(.top, 4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(MidnightTheme.cardBackground)
        .cornerRadius(16) // Adjusted from DesignSystem.cornerRadius (60) for better list appearance
    }
}
