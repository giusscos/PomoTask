//
//  OnboardingCheckInView.swift
//  TomaTask
//

import SwiftUI

struct OnboardingCheckInView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)
            
            Image(systemName: "bubble.left.and.text.bubble.right.fill")
                .font(.system(size: 56, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .onboardingPop(delay: 0.05)
            
            Text("How focused did you feel?")
                .font(.title.weight(.bold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.top, 28)
                .padding(.horizontal, 24)
                .onboardingPop(delay: 0.15)
            
            Text("After each focus block, a quick check-in tunes the next one.")
                .font(.body.weight(.medium))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .opacity(0.8)
                .padding(.horizontal, 28)
                .padding(.top, 12)
                .onboardingPop(delay: 0.25)
            
            VStack(spacing: 12) {
                checkInRow(
                    title: "In the flow",
                    subtitle: "Next block gets longer · starts right away",
                    delay: 0.35
                )
                checkInRow(
                    title: "A bit much",
                    subtitle: "Shorten the next block · you tap play",
                    delay: 0.45
                )
                checkInRow(
                    title: "Need a break",
                    subtitle: "A short break scaled to your last focus",
                    delay: 0.55
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            
            Spacer()
            
            NavigationLink {
                OnboardingStruggleView()
            } label: {
                OnboardingContinueButton(title: "Next")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
            .onboardingPop(delay: 0.65)
        }
        .onboardingChrome()
    }
    
    private func checkInRow(title: String, subtitle: String, delay: Double) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline.weight(.bold))
                .fontDesign(.rounded)
            Text(subtitle)
                .font(.caption.weight(.medium))
                .fontDesign(.rounded)
                .opacity(0.85)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onboardingPop(delay: delay)
    }
}

#Preview {
    NavigationStack {
        OnboardingCheckInView()
    }
}
