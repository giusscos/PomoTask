//
//  SubTask.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 19/04/25.
//

import Foundation
import SwiftData

@Model
class SubTask {
    var text: String = ""
    var isCompleted: Bool = false
    @Relationship var tomaTask: TomaTask?
    
    init(text: String, isCompleted: Bool = false) {
        self.text = text
        self.isCompleted = isCompleted
    }
}
