import SwiftUI

struct BouncyScaleButtonStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : (isSelected ? 1.05 : 1.0))
            .animation(.spring(response: 0.35, dampingFraction: 1, blendDuration: 0), value: configuration.isPressed)
            .animation(.spring(response: 0.35, dampingFraction: 1), value: isSelected)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed { Haptic.play(.light) }
            }
    }
}
