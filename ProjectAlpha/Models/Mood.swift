import SwiftUI

enum Mood: String, CaseIterable, Identifiable {
    case great = "Great"
    case good = "Good"
    case neutral = "Okay"
    case bad = "Bad"
    case terrible = "Awful"
    
    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .great: return "sun.max.fill"
        case .good: return "cloud.sun.fill"
        case .neutral: return "cloud.fill"
        case .bad: return "cloud.rain.fill"
        case .terrible: return "cloud.bolt.rain.fill"
        }
    }

    var color: Color {
        switch self {
        case .great: return Color(hex: "7FB95F")
        case .good: return Color(hex: "ADCC5F")
        case .neutral: return Color(hex: "E4CA37")
        case .bad: return Color(hex: "86B5D5")
        case .terrible: return Color(hex: "798FDE")
        }
    }
}
