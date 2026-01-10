import SwiftUI

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var startAnimation = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height
                    
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .white.opacity(0.1), location: 0.3),
                            .init(color: .white.opacity(0.6), location: 0.5),
                            .init(color: .white.opacity(0.1), location: 0.7),
                            .init(color: .clear, location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: width, height: height)
                    .rotationEffect(.degrees(20))
                    .offset(x: startAnimation ? width * 2 : -width * 2)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 2.5)
                    .repeatForever(autoreverses: false)
                ) {
                    startAnimation = true
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerEffect())
    }
}
