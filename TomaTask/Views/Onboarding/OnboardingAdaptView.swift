//
//  OnboardingAdaptView.swift
//  TomaTask
//

import SwiftUI

struct OnboardingAdaptView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            
            HStack(spacing: 12) {
                durationChip("5′", delay: 0.05)
                Image(systemName: "arrow.right")
                    .font(.title3.weight(.bold))
                    .opacity(0.7)
                    .onboardingPop(delay: 0.2)
                durationChip("8′", delay: 0.3)
                Image(systemName: "arrow.right")
                    .font(.title3.weight(.bold))
                    .opacity(0.7)
                    .onboardingPop(delay: 0.4)
                durationChip("11′", delay: 0.5)
            }
            .padding(.horizontal)
            
            Text("Start short. Grow with flow.")
                .font(.title.weight(.bold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.top, 36)
                .padding(.horizontal, 24)
                .onboardingPop(delay: 0.2)
            
            Text("Every focus block begins around 5 minutes. When you’re in the flow, the next block gets a little longer — up to 25 minutes.")
                .font(.body.weight(.medium))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .opacity(0.8)
                .padding(.horizontal, 28)
                .padding(.top, 16)
                .onboardingPop(delay: 0.35)
            
            Spacer()
            
            NavigationLink {
                OnboardingCheckInView()
            } label: {
                OnboardingContinueButton(title: "Next")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
            .onboardingPop(delay: 0.5)
        }
        .onboardingChrome()
    }
    
    private func durationChip(_ label: String, delay: Double) -> some View {
        Text(label)
            .font(.title2.weight(.bold))
            .fontDesign(.rounded)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onboardingPop(delay: delay)
    }
}

#Preview {
    NavigationStack {
        OnboardingAdaptView()
    }
}
