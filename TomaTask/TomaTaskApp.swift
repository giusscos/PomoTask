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
            TomaTasksList()
                .modelContainer(for: ModelData.self, isUndoEnabled: true)
        }
    }
}

