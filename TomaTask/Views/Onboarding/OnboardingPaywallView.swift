//
//  OnboardingPaywallView.swift
//  TomaTask
//

import SwiftUI

struct OnboardingPaywallView: View {
    @Environment(Store.self) private var store
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSeenWhatsNew") private var hasSeenWhatsNew = false
    @AppStorage(WhatsNew.lastSeenVersionKey) private var whatsNewLastSeenVersion = ""
    
    var body: some View {
        PaywallView(context: .onboarding, onClose: completeOnboarding)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
            .task {
                await store.updateCustomerProductStatus()
                if !store.purchasedSubscriptions.isEmpty {
                    completeOnboarding()
                }
            }
    }
    
    @MainActor
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        hasSeenWhatsNew = true
        whatsNewLastSeenVersion = WhatsNew.version
    }
}

#Preview {
    NavigationStack {
        OnboardingPaywallView()
    }
    .environment(Store())
}
