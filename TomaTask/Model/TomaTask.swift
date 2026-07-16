//
//  TomaTask.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 19/04/25.
//

import Foundation
import SwiftData

@Model
class TomaTask  {
    var title: String = ""
    var maxDuration: Int = 25
    var pauseDuration: Int = 5
    var repetition: Int = 4
    
    var category: Category = Category.work
    
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
        category: Category = Category.work
    ) {
        self.title = title
        self.maxDuration = maxDuration
        self.pauseDuration = pauseDuration
        self.repetition = repetition
        self.category = category
    }
}
