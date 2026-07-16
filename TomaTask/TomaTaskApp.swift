//
//  TomaTaskApp.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 25/09/24.
//

import SwiftUI
import SwiftData
import UserNotifications
import TipKit

@main
struct TomaTaskApp: App {
    let container: ModelContainer
    @State private var store = Store()
    
    init() {
        try? Tips.configure([.displayFrequency(.immediate)])
        do {
            container = try ModelContainer(for: TomaTask.self, Statistics.self)
            container.mainContext.undoManager = UndoManager()
            
            // Request notification permission at app launch
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
            }
        } catch {
            fatalError("Failed to initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarViewController()
                .environment(store)
                .onOpenURL { url in
                    guard url.scheme == "tomatask" else { return }
                    NotificationCenter.default.post(
                        name: .tomaTaskDeepLink,
                        object: nil,
                        userInfo: ["path": url.host ?? ""]
                    )
                }
        }.modelContainer(container)
    }
}

extension Notification.Name {
    static let tomaTaskDeepLink = Notification.Name("tomaTaskDeepLink")
}
