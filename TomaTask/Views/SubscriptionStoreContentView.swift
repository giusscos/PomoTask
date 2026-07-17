//
//  SubscriptionStoreContentView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 12/12/24.
//

import SwiftUI
import StoreKit

struct SubscriptionStoreContentView: View {
    @Environment(Store.self) private var store
    
    var body: some View {
        VStack(spacing: 0) {
            SubscriptionStoreView(groupID: store.groupId) {
                PaywallMarketingContent()
                    .background(OnboardingStyle.tomatoRed)
            }
            .scrollIndicators(.hidden)
            .subscriptionStoreControlStyle(.pagedPicker, placement: .bottomBar)
            .subscriptionStoreButtonLabel(.multiline)
            .storeButton(.visible, for: .restorePurchases)
            .tint(.white)
        }
        .background(OnboardingStyle.tomatoRed.ignoresSafeArea())
    }
}

#Preview {
    SubscriptionStoreContentView()
        .environment(Store())
}
