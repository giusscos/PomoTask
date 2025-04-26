//
//  TabBarViewController.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 22/10/24.
//

import SwiftUI

var featureSets: [(String, String, String)] = [
    ("Support", "hand.thumbsup.fill", "Help us to improve PomoTask for you and other users"),
    ("On device tracking", "chart.bar.fill", "Focus on your progress with clear charts and statistics"),
    ("New Themes", "swatchpalette.fill", "Personalize timers with your favorite colors and gradients"),
    ("New App Icons", "app.gift.fill", "Customize the app icon with multiple and fantastic designs"),
    ("iCloud Sync", "cloud.fill", "Stay focus and productive on all your devices"),
    ("Feature suggestions", "questionmark.app.fill", "Take the chance to request a feature for your PomoTask app"),
]

let screenSize = UIScreen.main.bounds.height

let defaultAppIcon = "AppIcon"

struct TabBarViewController: View {
    @AppStorage("appIcon") var appIcon: String = defaultAppIcon
    @AppStorage("hasSeenWhatsNew") private var hasSeenWhatsNew: Bool = false
    
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
                        ProgressiveTimerView()
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
        .onAppear() {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
        .fullScreenCover(isPresented: .constant(!hasSeenWhatsNew)) {
            WhatsNewView()
        }
    }
}

#Preview {
    TabBarViewController()
}
