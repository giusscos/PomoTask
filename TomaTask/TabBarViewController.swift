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

let screenSize = UIScreen.main.bounds.height

let defaultAppIcon = "AppIcon"

struct TabBarViewController: View {
    @AppStorage("appIcon") var appIcon: String = defaultAppIcon
    
    @State var store = Store()
    
    var body: some View {
        VStack {
            if store.products.isEmpty{
                ProgressView()
            } else {
                TabView {
                    Tab("Progressive", systemImage: "dial.medium") {
                        NavigationStack {
                            ProgressiveTimerList(store: store)
                        }
                    }
                    
                    Tab("Classic", systemImage: "timer") {
                        NavigationStack {
                            TomaTasksList()
                        }
                    }
                    
                    Tab("Settings", systemImage: "gear") {
                        NavigationStack {
                            SettingsView(appIcon: $appIcon, store: store)
                        }
                    }
                }
            }
        }
        .onAppear() {
            Task {
                try await store.fetchAvailableProducts()
                
                if !store.unlockAccess {
                    appIcon = defaultAppIcon
                }
                
                if let previousIcon = UIApplication.shared.alternateIconName {
                    if previousIcon != appIcon {
                        try await UIApplication.shared.setAlternateIconName(appIcon == defaultAppIcon ? nil : appIcon)
                    }
                }
            }
            
        }
    }
}

#Preview {
    TabBarViewController()
}
