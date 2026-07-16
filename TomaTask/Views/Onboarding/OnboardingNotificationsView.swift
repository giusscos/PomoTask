//
//  OnboardingNotificationsView.swift
//  TomaTask
//

import SwiftUI
import UserNotifications

struct OnboardingNotificationsView: View {
    @State private var isRequesting = false
    @State private var navigateToPaywall = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .onboardingPop(delay: 0.05)
            
            Text("Stay on track")
                .font(.title.weight(.bold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.top, 28)
                .padding(.horizontal, 24)
                .onboardingPop(delay: 0.15)
            
            Text("Get a nudge when a focus block or break ends — even if you’re in another app.")
                .font(.body.weight(.medium))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .opacity(0.8)
                .padding(.horizontal, 28)
                .padding(.top, 16)
                .onboardingPop(delay: 0.3)
            
            VStack(alignment: .leading, spacing: 14) {
                benefitRow("Focus complete", "Know when it’s time to check in", delay: 0.4)
                benefitRow("Break over", "Jump back in when you’re ready", delay: 0.5)
                benefitRow("You control it", "Change anytime in Settings", delay: 0.6)
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)
            
            Spacer()
            
            Button {
                requestNotificationPermission()
            } label: {
                OnboardingContinueButton(title: isRequesting ? "Asking…" : "Enable notifications")
            }
            .buttonStyle(.plain)
            .disabled(isRequesting)
            .padding(.horizontal, 24)
            .onboardingPop(delay: 0.7)
            
            Button {
                navigateToPaywall = true
            } label: {
                Text("Not now")
                    .font(.subheadline.weight(.semibold))
                    .fontDesign(.rounded)
                    .foregroundStyle(.white.opacity(0.75))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .onboardingPop(delay: 0.8)
        }
        .onboardingChrome()
        .navigationDestination(isPresented: $navigateToPaywall) {
            OnboardingPaywallView()
        }
    }
    
    private func benefitRow(_ title: String, _ subtitle: String, delay: Double) -> some View {
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
    
    private func requestNotificationPermission() {
        isRequesting = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            DispatchQueue.main.async {
                isRequesting = false
                navigateToPaywall = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingNotificationsView()
    }
}
