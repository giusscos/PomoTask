//
//  TomoTask.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class TomaTask  {
    var title: String
    var desc: String
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
    
    init(
        title: String = "TomaTask example",
        desc: String = "A standard pomodoro timer with a 25 minute work session and a 5 minute break session",
        maxDuration: TimeInterval = 25 * 60,
        pauseDuration: TimeInterval = 5 * 60,
        repetition: Int = 4,
        tasks: [SubTask] = [SubTask(text: "SubTomaTask 1", isCompleted: false)],
        category: Category = Category.work,
        status: Status = Status.rocket
    ) {
        self.title = title
        self.desc = desc
        self.maxDuration = maxDuration
        self.pauseDuration = pauseDuration
        self.repetition = repetition
        self.tasks = tasks
        self.category = category
        self.status = status
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
