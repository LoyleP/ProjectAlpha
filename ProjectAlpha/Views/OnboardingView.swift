import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentSlide = 0
    let slides = [
        OnboardingData(title: "Track Your Mind", description: "Log your daily emotional state with a single tap.", icon: "brain.head.profile"),
        OnboardingData(title: "Deep Insights", description: "Visualize your mood patterns with minimalist analytics.", icon: "chart.bar.xaxis"),
        OnboardingData(title: "Full Privacy", description: "Your data stays on your device. Always.", icon: "lock.shield.fill"),
    ]
    var body: some View {
        ZStack {
            MidnightTheme.background.ignoresSafeArea()
            VStack(spacing: 40) {
                TabView(selection: $currentSlide) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        VStack(spacing: 20) {
                            Image(systemName: slides[index].icon).font(.system(size: 80))
                                .foregroundStyle(MidnightTheme.accent).padding(.bottom, 20)
                            Text(slides[index].title)
                                .font(.system(size: DesignSystem.Typography.h1, weight: .bold, design: .rounded))
                                .foregroundStyle(MidnightTheme.accent)
                            Text(slides[index].description).font(.system(size: DesignSystem.Typography.p))
                                .multilineTextAlignment(.center).foregroundStyle(MidnightTheme.secondaryText)
                                .padding(.horizontal, 40)
                        }.tag(index)
                    }
                }.tabViewStyle(.page(indexDisplayMode: .always))
                VStack(spacing: 12) {
                    OnboardingButton(title: currentSlide < 2 ? "Next" : "Get Started", isPrimary: currentSlide < 2) {
                        if currentSlide < 2 {
                            withAnimation { currentSlide += 1 }
                        } else {
                            withAnimation { isPresented = true }
                        }
                    }
                }
                .padding(.horizontal, 30).padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingData: Identifiable {
    let id = UUID()
    let title: String, description: String, icon: String
}
