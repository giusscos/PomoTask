//
//  SubscriptionStoreContentView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 12/12/24.
//

import SwiftUI

/// Sheet wrapper for the Pro paywall (Settings, Statistics, locked Progressive tab).
struct SubscriptionStoreContentView: View {
    var context: PaywallContext = .general
    
    var body: some View {
        PaywallView(context: context)
    }
}

#Preview {
    SubscriptionStoreContentView()
        .environment(Store())
}
