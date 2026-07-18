//
//  TabBarViewController.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 22/10/24.
//

import SwiftUI

let screenSize = UIScreen.main.bounds.height

let defaultAppIcon = "TomatoAppIcon"

struct TabBarViewController: View {
    @Environment(Store.self) private var store
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("appIcon") var appIcon: String = defaultAppIcon
    @AppStorage("hasSeenWhatsNew") private var hasSeenWhatsNew: Bool = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var selectedTab: AppTab = .progressive
    
    private enum AppTab: Hashable {
        case statistics
        case progressive
        case classic
        case settings
    }
    
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
            TabView(selection: $selectedTab) {
                Tab("Statistics", systemImage: "chart.bar.fill", value: .statistics) {
                    NavigationStack {
                        StatisticsView()
                    }
                }
                
                Tab("Progressive", systemImage: "dial.medium", value: .progressive) {
                    NavigationStack {
                        if isSubscribed {
                            ProgressiveTimerView()
                        } else {
                            ProgressiveLockedView()
                        }
                    }
                }
                
                Tab("Classic", systemImage: "timer", value: .classic) {
                    NavigationStack {
                        TomaTasksList()
                    }
                }
                
                Tab("Settings", systemImage: "gear", value: .settings) {
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
            SharedStatsSync.publish(using: modelContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: .tomaTaskDeepLink)) { notification in
            guard let path = notification.userInfo?["path"] as? String else { return }
            if WidgetDeepLink.shouldOpenStatistics(path: path) {
                selectedTab = .statistics
                return
            }
            guard WidgetDeepLink.shouldOpenTimer(path: path) else { return }
            selectedTab = .progressive
            if WidgetDeepLink.shouldStartTimer(path: path) {
                WidgetDeepLink.pendingPlay = true
            }
        }
        .fullScreenCover(isPresented: showOnboarding) {
            OnboardingRootView()
                .environment(store)
        }
        .fullScreenCover(isPresented: .constant(hasCompletedOnboarding && !hasSeenWhatsNew)) {
            WhatsNewView()
        }
        .overlay {
            if store.isLoading {
                ZStack {
                    Color(uiColor: .systemBackground)
                        .ignoresSafeArea()
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    TabBarViewController()
        .environment(Store())
}
