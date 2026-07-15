//
//  TomaTaskActivityAttributes.swift
//  TomaTask
//

import ActivityKit
import Foundation

struct TomaTaskActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var endDate: Date
        var isBreak: Bool
        var isPaused: Bool
        var timeRemainingWhenPaused: TimeInterval
    }

    var taskTitle: String
}
