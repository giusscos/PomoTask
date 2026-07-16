//
//  TabBarViewController.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 22/10/24.
//

import SwiftUI

let screenSize = UIScreen.main.bounds.height

let defaultAppIcon = "AppIcon"

struct TabBarViewController: View {
    @Environment(Store.self) private var store
    
    @AppStorage("appIcon") var appIcon: String = defaultAppIcon
    @AppStorage("hasSeenWhatsNew") private var hasSeenWhatsNew: Bool = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    private var isSubscribed: Bool {
        !store.purchasedSubscriptions.isEmpty
    }
    
    private var showOnboarding: Binding<Bool> {
        Binding(
            get: { !hasCompletedOnboarding },
            set: { if !$0 { hasCompletedOnboarding = true } }
        )
    }
    
    var body: some View {
        VStack {
            TabView {
                Tab("Statistics", systemImage: "chart.bar.fill") {
                    NavigationStack {
                        StatisticsView()
                    }
                }
                
                Tab("Progressive", systemImage: "dial.medium") {
                    NavigationStack {
                        if isSubscribed {
                            ProgressiveTimerView()
                        } else {
                            ProgressiveLockedView()
                        }
                    }
                }
                
                Tab("Classic", systemImage: "timer") {
                    NavigationStack {
                        TomaTasksList()
                    }
                }
                
                Tab("Settings", systemImage: "gear") {
                    NavigationStack {
                        SettingsView(appIcon: $appIcon)
                    }
                }
            }
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
            // Existing users who already saw WhatsNew skip first-launch onboarding.
            if hasSeenWhatsNew && !hasCompletedOnboarding {
                hasCompletedOnboarding = true
            }
        }
        .fullScreenCover(isPresented: showOnboarding) {
            OnboardingRootView()
                .environment(store)
        }
        .fullScreenCover(isPresented: .constant(hasCompletedOnboarding && !hasSeenWhatsNew)) {
            WhatsNewView()
        }
    }
}

#Preview {
    TabBarViewController()
        .environment(Store())
}
