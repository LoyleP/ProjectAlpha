import SwiftUI

enum DesignSystem {
    enum Typography {
        static let h1: CGFloat = 28.38
        static let h2: CGFloat = 25.23
        static let h3: CGFloat = 22.43
        static let h4: CGFloat = 19.93
        static let h5: CGFloat = 17.72
        static let h6: CGFloat = 15.75
        static let p: CGFloat = 14.0
        static let small: CGFloat = 12.44
        static let tiny: CGFloat = 11.06
    }
    static let padding: CGFloat = 16.0
    static let cornerRadius: CGFloat = 60.0
}

enum MidnightTheme {
    static let background = Color(red: 0.05, green: 0.05, blue: 0.05).opacity(0.65)
    static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.14).opacity(0.65)
    static let accent = Color.white
    static let secondaryText = Color.gray
    static let destructive = Color.red
}
