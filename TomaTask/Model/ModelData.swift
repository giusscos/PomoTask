//
//  ModelData.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import Foundation

@Observable
class ModelData {
    var tomaTasks: [TomaTask] = []
    
    var profile = Profile.default
    
    var categories: [String: [TomaTask]] {
        Dictionary(
            grouping: tomaTasks,
            by: { $0.category.rawValue }
        )
    }
}
