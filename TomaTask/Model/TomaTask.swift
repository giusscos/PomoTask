//
//  TomoTask.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import Foundation
import SwiftUICore

struct TomaTask {
    var title: String
    var description: String
    var image: Image
    var isCompleted: Bool
    
    var tasks: [String]
    
    var category: Category
    enum Category: String, CaseIterable, Codable {
        case work = "Work"
        case study = "Study"
        case home = "Home"
        case wealth = "Wealth"
    }
}
