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
        SubscriptionStoreView(groupID: store.groupId) {
            PaywallMarketingContent()
                .background(OnboardingStyle.tomatoRed)
        }
        .background(OnboardingStyle.tomatoRed.ignoresSafeArea())
        .subscriptionStoreControlStyle(.compactPicker, placement: .bottomBar)
        .subscriptionStoreButtonLabel(.multiline)
        .storeButton(.visible, for: .restorePurchases)
        .tint(.white)
    }
}

#Preview {
    SubscriptionStoreContentView()
        .environment(Store())
}
