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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ModelData(tomaTasks: [TomaTask()], profile: Profile()))
        }
        .modelContainer(for: Storage.self)
    }
}
