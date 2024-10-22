//
//  TomaTaskApp.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 25/09/24.
//

import SwiftUI
import SwiftData

@main
struct TomaTaskApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: TomaTask.self, SubTask.self, migrationPlan: nil)
        } catch {
            fatalError("Error container initialization")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarViewController()
        }.modelContainer(container)
    }
}
