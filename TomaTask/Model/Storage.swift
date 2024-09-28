//
//  Storage.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 29/09/24.
//

import Foundation
import SwiftData

@Model
class Storage {
    var tomaTasks: [TomaTask]
    
    init(tomaTasks: [TomaTask] = [TomaTask()]) {
        self.tomaTasks = tomaTasks
    }
}

