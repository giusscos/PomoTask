//
//  TomaTaskApp.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 25/09/24.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct TomaTaskApp: App {
    let container: ModelContainer
    @State private var store = Store()
    
    init() {
        try? Tips.configure([.displayFrequency(.immediate)])
        WatchSessionManager.shared.activate()
        do {
            container = try ModelContainer(for: TomaTask.self, Statistics.self)
            container.mainContext.undoManager = UndoManager()
            #if DEBUG
            // Seeds demo data for screenshot runs.
            if ProcessInfo.processInfo.arguments.contains("-seedScreenshotData") {
                try? ScreenshotDataSeeder.seed(into: container.mainContext)
            }
            #endif
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
