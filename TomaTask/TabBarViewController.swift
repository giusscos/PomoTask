//
//  TabBarViewController.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 22/10/24.
//

import SwiftUI

var colorSets: [(Color, Color, Color)] = [
    (.black, .red, .orange),
    (.black, .green, .blue),
    (.black, .yellow, .purple),
    (.black, .indigo, .pink),
    (.black, .blue, .cyan)
]

var featureSets: [(String, String, String)] = [
    ("iCloud Sync", "cloud.fill", "Stay focus and productive on all your devices"),
    ("Progressive Timer", "dial.medium", "You can gradually build stronger focus endurance over time"),
    ("New Themes", "swatchpalette.fill", "Discover new visual and artistic themes every month"),
    ("New App Icons", "app.gift.fill", "Customize the app icon with multiple and fantastic designs"),
    ("Feature suggestions", "questionmark.app.fill", "Take the chance to request a feature for your PomoTask app"),
]

let screenSize = UIScreen.main.bounds.height

let defaultAppIcon = "AppIcon"

struct TabBarViewController: View {
    @AppStorage("appIcon") var appIcon: String = defaultAppIcon
    
    var body: some View {
        VStack {
            TabView {
                Tab("Progressive", systemImage: "dial.medium") {
                    NavigationStack {
                        ProgressiveTimerList()
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
    }
}

#Preview {
    TabBarViewController()
}
