//
//  OnboardingPaywallView.swift
//  TomaTask
//

import SwiftUI
import StoreKit

struct OnboardingPaywallView: View {
    @Environment(Store.self) private var store
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSeenWhatsNew") private var hasSeenWhatsNew = false
    
    var body: some View {
        VStack(spacing: 0) {
            SubscriptionStoreView(groupID: store.groupId) {
                PaywallMarketingContent(onContinueWithClassic: completeOnboarding)
                    .background(OnboardingStyle.tomatoRed)
            }
            .scrollIndicators(.hidden)
            .subscriptionStoreControlStyle(.pagedPicker, placement: .bottomBar)
            .subscriptionStoreButtonLabel(.multiline)
            .storeButton(.visible, for: .restorePurchases)
            .tint(.white)
            .onInAppPurchaseCompletion { product, result in
                guard case .success(.success(_)) = result else { return }
                await MainActor.run {
                    store.grantProduct(product)
                    completeOnboarding()
                }
            }
        }
        .background(OnboardingStyle.tomatoRed.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onChange(of: store.purchasedSubscriptions.count) { _, count in
            if count > 0 {
                completeOnboarding()
            }
        }
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
    }
}

#Preview {
    NavigationStack {
        OnboardingPaywallView()
    }
    .environment(Store())
}
