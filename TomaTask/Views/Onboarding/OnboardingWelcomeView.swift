//
//  OnboardingWelcomeView.swift
//  TomaTask
//

import SwiftUI

struct OnboardingWelcomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            
            Image(systemName: "dial.medium.fill")
                .font(.system(size: 72, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .onboardingPop(delay: 0.05)
            
            Text("TomaTask")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .padding(.top, 28)
                .onboardingPop(delay: 0.15)
            
            Text("Find your focus length")
                .font(.title3.weight(.semibold))
                .fontDesign(.rounded)
                .opacity(0.9)
                .padding(.top, 8)
                .onboardingPop(delay: 0.25)
            
            Text("Progressive Timer helps you discover how long you can truly focus — then gently stretch that edge.")
                .font(.body.weight(.medium))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .opacity(0.8)
                .padding(.horizontal, 28)
                .padding(.top, 20)
                .onboardingPop(delay: 0.35)
            
            Spacer()
            
            NavigationLink {
                OnboardingAdaptView()
            } label: {
                OnboardingContinueButton(title: "Show me how")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
            .onboardingPop(delay: 0.5)
        }
        .onboardingChrome()
    }
}

#Preview {
    NavigationStack {
        OnboardingWelcomeView()
    }
}
