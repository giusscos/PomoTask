//
//  OnboardingStruggleView.swift
//  TomaTask
//

import SwiftUI

struct OnboardingStruggleView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            
            Image(systemName: "exclamationmark.bubble.fill")
                .font(.system(size: 64, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .onboardingPop(delay: 0.05)
            
            Text("Stuck mid-session?")
                .font(.title.weight(.bold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.top, 28)
                .padding(.horizontal, 24)
                .onboardingPop(delay: 0.15)
            
            Text("Tap the struggle button anytime. Pause, shorten what’s left, or take a break — no guilt, just options.")
                .font(.body.weight(.medium))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .opacity(0.8)
                .padding(.horizontal, 28)
                .padding(.top, 16)
                .onboardingPop(delay: 0.3)
            
            VStack(alignment: .leading, spacing: 14) {
                strugglePoint("Keep going", "Resume when you’re ready", delay: 0.4)
                strugglePoint("Shorten remaining", "Cut about a third, then continue", delay: 0.5)
                strugglePoint("Break now", "Start a short recovery break", delay: 0.6)
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)
            
            Spacer()
            
            NavigationLink {
                OnboardingNotificationsView()
            } label: {
                OnboardingContinueButton(title: "Next")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
            .onboardingPop(delay: 0.7)
        }
        .onboardingChrome()
    }
    
    private func strugglePoint(_ title: String, _ subtitle: String, delay: Double) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .fontDesign(.rounded)
                Text(subtitle)
                    .font(.subheadline.weight(.medium))
                    .fontDesign(.rounded)
                    .opacity(0.8)
            }
        }
        .onboardingPop(delay: delay)
    }
}

#Preview {
    NavigationStack {
        OnboardingStruggleView()
    }
}
