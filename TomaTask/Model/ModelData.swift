//
//  ModelData.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import Foundation
import SwiftData

@Model
class ModelData {
    var tomaTasks: [TomaTask]
    var profile: Profile
    
    init(tomaTasks: [TomaTask] = [TomaTask()], profile: Profile = Profile()) {
        self.tomaTasks = tomaTasks
        self.profile = profile
    }
}
