//
//  OnboardingPopModifier.swift
//  TomaTask
//

import SwiftUI

enum OnboardingStyle {
    static let tomatoRed = Color(red: 0.86, green: 0.14, blue: 0.14)
    static let popSpring = Animation.spring(response: 0.45, dampingFraction: 0.65)
}

enum LegalURLs {
    static let privacyPolicy = URL(string: "https://giusscos.it/privacy")!
    static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
}

struct OnboardingPopModifier: ViewModifier {
    let delay: Double
    @State private var appeared = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1 : 0.72)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(OnboardingStyle.popSpring.delay(delay)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func onboardingPop(delay: Double = 0) -> some View {
        modifier(OnboardingPopModifier(delay: delay))
    }
}

struct OnboardingContinueButton: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline.weight(.bold))
            .fontDesign(.rounded)
            .foregroundStyle(OnboardingStyle.tomatoRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

struct OnboardingChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.white)
            .background(OnboardingStyle.tomatoRed.ignoresSafeArea())
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarBackButtonHidden(false)
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    func onboardingChrome() -> some View {
        modifier(OnboardingChrome())
    }
}
