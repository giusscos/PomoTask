//
//  ModelData.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import Foundation
import SwiftData

@Model
@Observable
class ModelData {
    var tomaTasks: [TomaTask]
    var profile: Profile
    
    init(tomaTasks: [TomaTask], profile: Profile) {
        self.tomaTasks = tomaTasks
        self.profile = profile
    }
    
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
        desc: String,
        maxDuration: Int,
        pauseDuration: Int,
        repetition: Int,
        tasks: [SubTask],
        category: TomaTask.Category,
        status: TomaTask.Status
    ) {
        let newTask = TomaTask(
            title: title,
            desc: desc,
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
