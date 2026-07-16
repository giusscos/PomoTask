//
//  PaywallContent.swift
//  TomaTask
//

import SwiftUI

struct ProFeature: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let subtitle: String
}

let proFeatures: [ProFeature] = [
    ProFeature(
        title: "Progressive Timer",
        icon: "dial.medium.fill",
        subtitle: "Start around 5′, grow when you’re in flow, up to 25′"
    ),
    ProFeature(
        title: "Smart check-ins",
        icon: "bubble.left.and.text.bubble.right.fill",
        subtitle: "After each block: go longer, shorten, or take a break"
    ),
    ProFeature(
        title: "Struggle escape",
        icon: "exclamationmark.bubble.fill",
        subtitle: "Pause, cut remaining time, or break — anytime mid-session"
    ),
    ProFeature(
        title: "Focus statistics",
        icon: "chart.bar.fill",
        subtitle: "See focus time, starts, and completions on device"
    ),
    ProFeature(
        title: "Themes & icons",
        icon: "swatchpalette.fill",
        subtitle: "Colors, gradients, and handcrafted app icons"
    ),
]

/// Shared marketing header — tomato field + pop animations, matching onboarding.
struct PaywallMarketingContent: View {
    var onContinueWithClassic: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dial.medium.fill")
                .font(.system(size: 56, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .onboardingPop(delay: 0.05)
            
            VStack(spacing: 10) {
                Text("Unlock Progressive")
                    .font(.largeTitle.weight(.bold))
                    .fontDesign(.rounded)
                
                Text("Find your focus length — then grow it with adaptive blocks, check-ins, and clear stats.")
                    .font(.body.weight(.medium))
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .opacity(0.85)
                    .padding(.horizontal, 8)
            }
            .onboardingPop(delay: 0.15)
            
            VStack(spacing: 12) {
                ForEach(Array(proFeatures.enumerated()), id: \.element.id) { index, feature in
                    PaywallFeatureRow(feature: feature)
                        .onboardingPop(delay: 0.28 + Double(index) * 0.08)
                }
                
                if let onContinueWithClassic {
                    Button(action: onContinueWithClassic) {
                        Text("Continue with Classic")
                            .font(.subheadline.weight(.semibold))
                            .fontDesign(.rounded)
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .onboardingPop(delay: 0.28 + Double(proFeatures.count) * 0.08)
                }

                HStack(spacing: 16) {
                    Link("Privacy Policy", destination: LegalURLs.privacyPolicy)
                        .buttonStyle(.plain)

                    Text("·")
                        .opacity(0.5)
                    
                    Link("Terms of Use", destination: LegalURLs.termsOfUse)
                        .buttonStyle(.plain)
                }
                .font(.footnote.weight(.semibold))
                .fontDesign(.rounded)
                .foregroundStyle(.white.opacity(0.85))
                .padding(.top, 8)
                .onboardingPop(delay: 0.28 + Double(proFeatures.count + 1) * 0.08)
            }
            .padding(.top, 8)
        }
        .foregroundStyle(.white)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}

struct PaywallFeatureRow: View {
    let feature: ProFeature
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: feature.icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(OnboardingStyle.tomatoRed)
                .frame(width: 40, height: 40)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.headline.weight(.bold))
                    .fontDesign(.rounded)
                
                Text(feature.subtitle)
                    .font(.caption.weight(.medium))
                    .fontDesign(.rounded)
                    .opacity(0.85)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
