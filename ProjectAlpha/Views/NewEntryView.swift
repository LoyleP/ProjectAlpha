import SwiftUI
import SwiftData

struct NewEntryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    // MARK: - Form State
    @State private var selectedMood: Mood = .good
    @State private var energyLevel: Double = 5.0
    @State private var note: String = ""
    @State private var entryDate: Date = Date()
    @State private var scrollID: Mood?
    
    // Focus state for the keyboard
    @FocusState private var isNoteFocused: Bool
    
    var isValid: Bool {
        !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                MidnightTheme.background
                    .ignoresSafeArea()
                    .onTapGesture {
                    isNoteFocused = false
                }
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // SECTION 1: MOOD CAROUSEL
                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader(title: "How are you feeling?", subtitle: "Select your current mood")
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(Mood.allCases) { mood in
                                        MoodCarouselItem(mood: mood, isSelected: selectedMood == mood)
                                            .id(mood)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                    selectedMood = mood
                                                    scrollID = mood
                                                }
                                            }
                                            .containerRelativeFrame(.horizontal, count: 2, spacing: 12)
                                            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                                content
                                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                                                    .opacity(phase.isIdentity ? 1.0 : 0.5)
                                            }
                                    }
                                }
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.viewAligned)
                            .scrollPosition(id: $scrollID)
                            .contentMargins(.horizontal, 20, for: .scrollContent)
                            .frame(height: 220)
                        }
                        
                        // SECTION 2: ENERGY & TIME (Grouped for better UX)
                        VStack(spacing: 20) {
                            // Energy Slider
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label("Energy Level", systemImage: "bolt.fill")
                                        .font(.system(size: DesignSystem.Typography.h6, weight: .semibold))
                                    Spacer()
                                    Text("\(Int(energyLevel))/10")
                                        .font(.system(size: DesignSystem.Typography.p, weight: .bold))
                                        .foregroundStyle(selectedMood.color)
                                }
                                
                                Slider(value: $energyLevel, in: 1...10, step: 1)
                                    .tint(selectedMood.color)
                            }
                            .padding()
                            .background(MidnightTheme.cardBackground.opacity(0.8))
                            .cornerRadius(20)
                            
                            // Split Date & Time Pickers
                            VStack(spacing: 16) {
                                // Date Picker (as requested with closure label)
                                DatePicker(
                                    selection: $entryDate,
                                    in: ...Date(),
                                    displayedComponents: .date,
                                    label: {
                                        Label("Date", systemImage: "calendar")
                                            .font(.system(size: DesignSystem.Typography.p, weight: .medium))
                                    }
                                )
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                // Time Picker (as requested with string label)
                                DatePicker(
                                    "Time",
                                    selection: $entryDate,
                                    displayedComponents: .hourAndMinute
                                )
                                .font(.system(size: DesignSystem.Typography.p, weight: .medium))
                            }
                            .padding()
                            .background(MidnightTheme.cardBackground.opacity(0.8))
                            .cornerRadius(20)
                            .tint(selectedMood.color) // Makes the picker popover match the mood color
                        }
                        .padding(.horizontal)
                        
                        // SECTION 3: NOTE
                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader(title: "Daily Note", subtitle: "What's on your mind?")
                            
                            TextField("How was your day?", text: $note, axis: .vertical) // Axis allows it to grow as you type
                                .lineLimit(5...10) // Sets a minimum height of 5 lines and max of 10 before scrolling
                                .font(.system(size: DesignSystem.Typography.p))
                                .foregroundStyle(MidnightTheme.accent)
                                .padding()
                                .background(MidnightTheme.cardBackground.opacity(0.8))
                                .cornerRadius(20) // Consistent with previous card styling
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(isNoteFocused ? selectedMood.color.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .focused($isNoteFocused)
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100) // Space for keyboard/scrolling
                    }
                    .padding(.vertical)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                // Leading Action: Cross Icon
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: DesignSystem.Typography.p, weight: .medium))
                            .foregroundStyle(MidnightTheme.secondaryText)
                    }
                    .accessibilityLabel("Close")
                }

                // Trailing Action: Clean Text Save
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveEntry) {
                        Text("Save")
                            .foregroundStyle(isValid ? MidnightTheme.accent : MidnightTheme.secondaryText.opacity(0.5))
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    // Helper view for consistent headers
    @ViewBuilder
    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: DesignSystem.Typography.h5, weight: .bold))
                .foregroundStyle(MidnightTheme.accent)
            Text(subtitle)
                .font(.system(size: DesignSystem.Typography.small))
                .foregroundStyle(MidnightTheme.secondaryText)
        }
        .padding(.horizontal)
    }

    private func saveEntry() {
        // 1. Create the entry using the initializer you defined in MoodEntry.swift
        let newEntry = MoodEntry(
            mood: selectedMood,
            energy: Int(energyLevel),
            note: note
        )
        
        // 2. Override the timestamp with the specific date/time from your pickers
        newEntry.timestamp = entryDate
        
        // 3. Insert into the model context
        modelContext.insert(newEntry)
        
        // 4. Force a manual save to ensure the HistoryView @Query updates instantly
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving entry: \(error.localizedDescription)")
        }
    }
}
