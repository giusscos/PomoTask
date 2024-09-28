//
//  ModelData.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import Foundation

@Observable
class ModelData {
    var tomaTasks: [TomaTask] = [
        TomaTask(
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
    ]
    
    var profile = Profile.default
    
    var categories: [String: [TomaTask]] {
        Dictionary(
            grouping: tomaTasks,
            by: { $0.category.rawValue }
        )
    }
    
    var status: [String: [TomaTask]] {
        Dictionary(
            grouping: tomaTasks,
            by: { $0.status.rawValue }
        )
    }
    
    func addTask(
        title: String,
        description: String,
        maxDuration: Int,
        pauseDuration: Int,
        repetition: Int,
        tasks: [SubTask],
        category: TomaTask.Category,
        status: TomaTask.Status
    ) {
        let newTask = TomaTask(
            id: UUID().uuidString,
            title: title,
            description: description,
            maxDuration: Double(maxDuration * 60),
            pauseDuration: Double(pauseDuration * 60),
            repetition: repetition,
            tasks: tasks,
            category: category,
            status: status
        )
        
        tomaTasks.append(newTask)
    }
}
