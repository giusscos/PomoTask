//
//  ModelSchema.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 15/10/24.
//

import Foundation
import SwiftUI
import SwiftData

enum ModelSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [TomaTask.self, SubTask.self ]
    }
    
    @Model
    class TomaTask  {
        var title: String
        var maxDuration: Int
        var pauseDuration: Int
        var repetition: Int
        @Relationship(deleteRule: .cascade) var tasks: [SubTask]
        
        var category: Category
        enum Category: String, CaseIterable, Codable, Identifiable {
            case work = "💼 Work"
            case study = "🧠 Study"
            case home = "🏠 Home"
            case wealth = "🫀 Wealth"
            
            var id: String { rawValue }
        }
        
        init(
            title: String = "",
            maxDuration: Int = 25,
            pauseDuration: Int = 5,
            repetition: Int = 4,
            tasks: [SubTask] = [],
            category: Category = Category.work
        ) {
            self.title = title
            self.maxDuration = maxDuration
            self.pauseDuration = pauseDuration
            self.repetition = repetition
            self.tasks = tasks
            self.category = category
        }
    }
    
    @Model
    class SubTask {
        var text: String
        var isCompleted: Bool
        
        init(text: String, isCompleted: Bool = false) {
            self.text = text
            self.isCompleted = isCompleted
        }
    }
}
