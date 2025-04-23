//
//  TomaTaskApp.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 25/09/24.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct TomaTaskApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: TomaTask.self, SubTask.self, Statistics.self)
            
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
        }.modelContainer(container)
    }
}
