//
//  TomoTask.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import Foundation
import SwiftUI

struct TomaTask: Hashable, Codable, Identifiable  {
    
    var id: String
    var title: String
    var description: String
    var maxDuration: TimeInterval
    var pauseDuration: TimeInterval
    var repetition: Int
    var tasks: [SubTask]

    var category: Category
    enum Category: String, CaseIterable, Codable, Identifiable {
        case work = "💼 Work"
        case study = "🧠 Study"
        case home = "🏠 Home"
        case wealth = "🫀 Wealth"
        
        var id: String { rawValue }
    }
    
    var status: Status
    enum Status: String, CaseIterable, Codable, Identifiable {
        case complete = "✅"
        case rocket = "🚀"
        case alien = "👾"
        case planning = "🗓️"
        
        var id: String { rawValue }
    }
    
    static let `default` = TomaTask(
                id: UUID().uuidString,
                title: "TomaTask example",
                description: "A standard pomodoro timer with a 25 minute work session and a 5 minute break session",
                maxDuration: 25 * 60,
                pauseDuration: 5 * 60,
                repetition: 4,
                tasks: [SubTask(text: "Read"),
                        SubTask(text: "Write"),
                        SubTask(text: "Review"),
                        SubTask(text: "Deploy")],
                category: TomaTask.Category.work,
                status: TomaTask.Status.rocket
            )
}

struct SubTask: Hashable, Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString
    var text: String
    var isCompleted: Bool = false
    
    init(id: String = UUID().uuidString, text: String, isCompleted: Bool = false) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
    }
}
