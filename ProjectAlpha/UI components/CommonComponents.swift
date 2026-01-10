import SwiftUI

struct StatCard: View {
    let title: String, value: String, subtitle: String, icon: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.system(size: DesignSystem.Typography.tiny, weight: .bold))
                    .foregroundStyle(MidnightTheme.secondaryText)
                Spacer()
                Image(systemName: icon).font(.system(size: 10))
                    .foregroundStyle(MidnightTheme.secondaryText)
            }
            HStack(alignment: .bottom, spacing: 4) {
                Text(value).font(.system(size: DesignSystem.Typography.h2, weight: .bold, design: .rounded))
                    .foregroundStyle(MidnightTheme.accent)
                Text(subtitle).font(.system(size: DesignSystem.Typography.tiny))
                    .foregroundStyle(MidnightTheme.secondaryText).padding(.bottom, 4)
            }
        }
        .padding().frame(maxWidth: .infinity, alignment: .leading)
        .background(MidnightTheme.cardBackground.opacity(0.65))
        .cornerRadius(16)
        // MARK: - Added Stroke Overlay
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
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
