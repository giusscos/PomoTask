//
//  OnboardingRootView.swift
//  TomaTask
//

import SwiftUI

struct OnboardingRootView: View {
    var body: some View {
        NavigationStack {
            OnboardingWelcomeView()
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    OnboardingRootView()
        .environment(Store())
}
