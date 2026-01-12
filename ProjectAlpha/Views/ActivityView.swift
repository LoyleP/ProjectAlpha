import SwiftUI
import SwiftData

struct ActivityView: View {
    @Query(sort: \MoodEntry.timestamp, order: .forward) var entries: [MoodEntry]
    
    // MARK: - State
    @State private var currentMonth: Date = Date()
    @State private var selectedEntry: MoodEntry?
    
    // MARK: - Layout Constants
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Activity")
                    .font(.title.weight(.bold))
                    .foregroundStyle(MidnightTheme.accent)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 60)
            .padding(.bottom, 20)

            ScrollView {
                VStack(spacing: 30) {
                    
                    // Month Navigation
                    HStack {
                        Button(action: { changeMonth(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.bold))
                                .foregroundStyle(MidnightTheme.secondaryText)
                                .padding(8)
                                .background(Color.white.opacity(0.05))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // FIXED: Corrected font definition
                        Text(monthYearString(from: currentMonth))
                            .font(.system(.title3, design: .rounded, weight: .bold)) // Corrected
                            .foregroundStyle(MidnightTheme.accent)
                        
                        Spacer()
                        
                        Button(action: { changeMonth(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.bold))
                                .foregroundStyle(MidnightTheme.secondaryText)
                                .padding(8)
                                .background(Color.white.opacity(0.05))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)

                    // Calendar Grid
                    VStack(spacing: 15) {
                        // Weekday Headers
                        HStack {
                            ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                                Text(day.prefix(1))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(MidnightTheme.secondaryText)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        // Days Grid
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(daysInMonth(), id: \.self) { date in
                                if let date = date {
                                    dayCell(for: date)
                                } else {
                                    Color.clear.aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(MidnightTheme.cardBackground.opacity(0.65))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Footer Info
                    if !entries.isEmpty {
                        Text("Mood history for \(monthYearString(from: currentMonth))")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MidnightTheme.secondaryText)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .background(MidnightTheme.background)
        // MARK: - Pop-up Drawer
        .sheet(item: $selectedEntry) { entry in
            EntryDetailView(entry: entry)
                .presentationDetents([.fraction(0.60)])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Subviews
    
    private func dayCell(for date: Date) -> some View {
        let entry = entries.first { calendar.isDate($0.timestamp, inSameDayAs: date) }
        let mood = entry != nil ? Mood(rawValue: entry!.moodName) : nil
        let isFuture = date > Date()
        
        return VStack(spacing: 4) {
            ZStack {
                if let mood = mood {
                    // Filled Circle with Tap Action
                    Circle()
                        .fill(mood.color)
                        .shadow(color: mood.color.opacity(0.4), radius: 4, x: 0, y: 2)
                        .onTapGesture {
                            selectedEntry = entry
                        }
                } else {
                    // Empty Circle
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            
            Text("\(calendar.component(.day, from: date))")
                .font(.caption2.weight(.medium))
                .foregroundStyle(
                    mood != nil ? MidnightTheme.accent : MidnightTheme.secondaryText.opacity(isFuture ? 0.3 : 0.8)
                )
        }
    }

    // MARK: - Logic Helpers

    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation() {
                currentMonth = newDate
            }
        }
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func daysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let paddingDays = firstWeekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: paddingDays)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        return days
    }
}

// MARK: - Entry Detail Drawer
// MARK: - Entry Detail Drawer
struct EntryDetailView: View {
    @Environment(\.dismiss) var dismiss
    let entry: MoodEntry
    var mood: Mood? { Mood(rawValue: entry.moodName) }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            MidnightTheme.cardBackground.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header: Icon and Date
                VStack(spacing: 8) {
                    if let mood = mood {
                        Image(systemName: mood.icon)
                            .font(.system(size: 48))
                            .foregroundStyle(mood.color)
                            .padding(.bottom, 8)
                    }
                    
                    Text(entry.timestamp.formatted(date: .complete, time: .omitted))
                        .font(.headline)
                        .foregroundStyle(MidnightTheme.secondaryText)
                    
                    if let mood = mood {
                        Text(mood.rawValue)
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(MidnightTheme.accent)
                    }
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                // Stats Grid
                HStack(spacing: 40) {
                    VStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(mood?.color ?? .white)
                        Text("Energy")
                            .font(.caption)
                            .foregroundStyle(MidnightTheme.secondaryText)
                        Text("\(entry.energy)/10")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(MidnightTheme.accent)
                    }
                    
                    VStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(mood?.color ?? .white)
                        Text("Time")
                            .font(.caption)
                            .foregroundStyle(MidnightTheme.secondaryText)
                        Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.title3.weight(.bold))
                            .foregroundStyle(MidnightTheme.accent)
                    }
                }
                
                // Note Section
                if !entry.note.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(MidnightTheme.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(entry.note)
                            .font(.body)
                            .foregroundStyle(MidnightTheme.accent)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding(24)
            .padding(.top, 50)
        }
    }
}
