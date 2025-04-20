//
//  TomaTaskWatchApp.swift
//  TomaTaskWatch Watch App
//
//  Created by Giuseppe Cosenza on 20/04/25.
//

import SwiftUI
import SwiftData

@main
struct TomaTaskWatch_Watch_AppApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: TomaTask.self, SubTask.self, Statistics.self)
        } catch {
            fatalError("Failed to initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
