//
//  TabBarViewController.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 22/10/24.
//

import SwiftUI
import TipKit

let screenSize = UIScreen.main.bounds.height

let defaultAppIcon = "TomatoAppIcon"

struct TabBarViewController: View {
    @Environment(Store.self) private var store
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("appIcon") var appIcon: String = defaultAppIcon
    @AppStorage("hasSeenWhatsNew") private var hasSeenWhatsNew: Bool = false
    @AppStorage(WhatsNew.lastSeenVersionKey) private var whatsNewLastSeenVersion: String = ""
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage(ProgressiveTrial.freeSessionsUsedKey) private var progressiveFreeSessionsUsed = 0
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
                        if isSubscribed || ProgressiveTrial.hasRemaining(used: progressiveFreeSessionsUsed) {
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
            updateStartTimerTipEligibility()
        }
        .onChange(of: hasCompletedOnboarding) { updateStartTimerTipEligibility() }
        .onChange(of: whatsNewLastSeenVersion) { updateStartTimerTipEligibility() }
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
        .fullScreenCover(isPresented: .constant(isShowingWhatsNew)) {
            WhatsNewView()
                .environment(store)
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

extension TabBarViewController {
    private var isShowingWhatsNew: Bool {
        hasCompletedOnboarding && whatsNewLastSeenVersion != WhatsNew.version
    }
    
    private func updateStartTimerTipEligibility() {
        StartTimerTip.isOnboardingComplete = hasCompletedOnboarding && !isShowingWhatsNew
    }
}

#Preview {
    TabBarViewController()
        .environment(Store())
}
